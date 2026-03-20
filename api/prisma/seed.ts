import prisma from "../src/config/prisma";
import bcrypt from "bcrypt";

const SALT_ROUNDS = 12;

interface SeedUser {
  email: string;
  name: string;
  password: string;
}

const users: SeedUser[] = [
  {
    email: "admin@handlerclaw.local",
    name: "Administrator",
    password: "admin123",
  },
];

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function main(): Promise<void> {
  console.log("🌱 Starting seed...");

  for (const user of users) {
    const hashedPassword = await hashPassword(user.password);

    const created = await prisma.user.upsert({
      where: { email: user.email },
      update: {
        name: user.name,
        password: hashedPassword,
      },
      create: {
        email: user.email,
        name: user.name,
        password: hashedPassword,
      },
    });

    console.log(`✅ User created/updated: ${created.email}`);
  }

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
