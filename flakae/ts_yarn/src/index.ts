import chalk from "chalk";

const greeting: string = "Hello";

function add(a: number, b: number): number {
  return a + b;
}

export function run() {
  console.log(chalk.magenta(`${greeting}: 5 + 10 = ${add(5, 10)}`));
}

run();
