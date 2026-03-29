import prisma from "../src/config/prisma.js";
import bcrypt from "bcrypt";

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function main(): Promise<void> {
  console.log("🌱 Starting seed...");

  const defaultEmail = process.env.DEFAULT_USER_EMAIL;
  const defaultName = process.env.DEFAULT_USER_NAME;
  const defaultPassword = process.env.DEFAULT_USER_PASSWORD;

  if (!defaultEmail || !defaultName || !defaultPassword) {
    console.log("⚠️ Skipping default user seeding: Missing environment variables.");
    return;
  }

  const hashedPassword = await hashPassword(defaultPassword);

  const created = await prisma.user.upsert({
    where: { email: defaultEmail },
    update: {
      name: defaultName,
      password: hashedPassword,
    },
    create: {
      email: defaultEmail,
      name: defaultName,
      password: hashedPassword,
      avatarUrl: "https://i.pravatar.cc/300",
    },
  });

  console.log(`✅ Default user created/updated: ${created.email}`);
  console.log("🎉 Seed completed successfully");
}

main()
  .catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
