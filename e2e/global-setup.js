const { chromium } = require('@playwright/test');

module.exports = async function globalSetup(config) {
  const { baseURL } = config.projects[0].use;
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const response = await page.goto(`${baseURL}/test/sign_in`);
  if (!response.ok()) throw new Error(`Sign-in failed: ${response.status()}`);
  await page.context().storageState({ path: 'e2e/.auth-state.json' });

  await browser.close();
};
