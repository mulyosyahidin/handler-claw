import { prisma } from "../../../../../../config/index.js";
import type {
  GetFinanceOverviewResponse,
  FinanceOverviewAccountItem,
  FinanceOverviewAccountTypeItem,
  FinanceOverviewTopMover,
} from "../dtos/finance-overview.dto.js";

export class GetFinanceOverviewUseCase {
  async execute(userId: string): Promise<GetFinanceOverviewResponse> {
    // 1. Fetch Account Types for the user
    const accountTypes = await prisma.accountType.findMany({
      where: { userId, deletedAt: null },
      orderBy: { name: "asc" },
    });

    // 2. Fetch Accounts with their latest snapshots (last 5 records)
    const accounts = await prisma.account.findMany({
      where: { userId, deletedAt: null },
      include: {
        balances: {
          where: { deletedAt: null },
          orderBy: { date: "desc" },
          take: 5,
        },
      },
      orderBy: { name: "asc" },
    });

    // 3. Map Accounts and calculate their current total per Type
    const typeTotals = new Map<string, number>();
    const typeCounts = new Map<string, number>();

    // Initialize totals and counts with 0 for all active types
    accountTypes.forEach((t) => {
      typeTotals.set(t.id, 0);
      typeCounts.set(t.id, 0);
    });

    let totalNetWorth = 0;
    const categoryTotals = {
      liquid: 0,
      debt: 0,
      investment: 0,
    };

    const accountItems: FinanceOverviewAccountItem[] = accounts.map((acc) => {
      const latestSnapshot = acc.balances[0]; // ordered by date desc
      const currentAmount = latestSnapshot ? Number(latestSnapshot.amount) : 0;

      // Add to type total (if the type is not deleted)
      const type = accountTypes.find((t) => t.id === acc.accountTypeId);
      if (type) {
        const currentTypeTotal = typeTotals.get(type.id) || 0;
        typeTotals.set(type.id, currentTypeTotal + currentAmount);

        const currentTypeCount = typeCounts.get(type.id) || 0;
        typeCounts.set(type.id, currentTypeCount + 1);

        // Update Category Totals and Net Worth
        if (type.category === "DEBT") {
          categoryTotals.debt += currentAmount;
          totalNetWorth -= currentAmount;
        } else if (type.category === "INVESTMENT") {
          categoryTotals.investment += currentAmount;
          totalNetWorth += currentAmount;
        } else if (type.category === "LIQUID") {
          categoryTotals.liquid += currentAmount;
          totalNetWorth += currentAmount;
        }
      }

      return {
        id: acc.id,
        name: acc.name,
        category: type?.category ?? "LIQUID",
        current_amount: currentAmount,
      };
    });

    const accountTypeItems: FinanceOverviewAccountTypeItem[] = accountTypes.map((t) => ({
      id: t.id,
      name: t.name,
      category: t.category,
      current_total_amount: typeTotals.get(t.id) || 0,
      account_count: typeCounts.get(t.id) || 0,
    }));

    // 4. Calculate Advanced Metrics
    const totalAssets = categoryTotals.liquid + categoryTotals.investment;
    const totalValue = totalAssets + categoryTotals.debt;

    const allocation = {
      liquid_pct: totalValue > 0 ? (categoryTotals.liquid / totalValue) * 100 : 0,
      debt_pct: totalValue > 0 ? (categoryTotals.debt / totalValue) * 100 : 0,
      investment_pct: totalValue > 0 ? (categoryTotals.investment / totalValue) * 100 : 0,
    };

    const ratios = {
      debt_to_asset_ratio: totalAssets > 0 ? categoryTotals.debt / totalAssets : 0,
    };

    // 5. Calculate Top Movers (30-day change)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    thirtyDaysAgo.setHours(0, 0, 0, 0);

    const previousSnapshots = await prisma.balanceSnapshot.findMany({
      where: {
        account: { userId, deletedAt: null },
        date: { lte: thirtyDaysAgo },
        deletedAt: null,
      },
      orderBy: [{ accountId: "asc" }, { date: "desc" }],
      distinct: ["accountId"],
    });

    const previousBalances = new Map<string, number>();
    previousSnapshots.forEach((s) => previousBalances.set(s.accountId, Number(s.amount)));

    const topMovers: FinanceOverviewTopMover[] = accountItems
      .map((acc) => {
        const prevAmount = previousBalances.get(acc.id) ?? acc.current_amount;
        const amountChange = acc.current_amount - prevAmount;
        const percentageChange = prevAmount > 0 ? (amountChange / prevAmount) * 100 : 0;

        let direction: "UP" | "DOWN" | "STABLE" = "STABLE";
        if (amountChange > 0) direction = "UP";
        else if (amountChange < 0) direction = "DOWN";

        return {
          id: acc.id,
          name: acc.name,
          amount_change: amountChange,
          percentage_change: percentageChange,
          direction,
        };
      })
      .filter((m) => m.amount_change !== 0)
      .sort((a, b) => Math.abs(b.amount_change) - Math.abs(a.amount_change))
      .slice(0, 3);

    return {
      account_types: accountTypeItems,
      accounts: accountItems,
      categories: categoryTotals,
      allocation,
      ratios,
      top_movers: topMovers,
      total_net_worth: totalNetWorth,
    };
  }
}
