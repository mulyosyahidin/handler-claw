import type { IAccountSnapshot } from "../../../account-snapshots/domain/entities/account-snapshot.entity.js";

export type FinanceOverviewAccountTypeItem = {
  id: string;
  name: string;
  category: string;
  current_total_amount: number;
};

export type FinanceOverviewAccountItem = {
  id: string;
  name: string;
  current_amount: number;
  snapshots: IAccountSnapshot[];
};

export type FinanceOverviewCategoryTotals = {
  liquid: number;
  debt: number;
  investment: number;
};

export type FinanceOverviewAllocation = {
  liquid_pct: number;
  debt_pct: number;
  investment_pct: number;
};

export type FinanceOverviewRatios = {
  debt_to_asset_ratio: number;
};

export type FinanceOverviewTopMover = {
  id: string;
  name: string;
  amount_change: number;
  percentage_change: number;
  direction: "UP" | "DOWN" | "STABLE";
};

export type GetFinanceOverviewResponse = {
  account_types: FinanceOverviewAccountTypeItem[];
  accounts: FinanceOverviewAccountItem[];
  categories: FinanceOverviewCategoryTotals;
  allocation: FinanceOverviewAllocation;
  ratios: FinanceOverviewRatios;
  top_movers: FinanceOverviewTopMover[];
  total_net_worth: number;
};
