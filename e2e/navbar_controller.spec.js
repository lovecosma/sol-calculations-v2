const { test, expect } = require('@playwright/test');

test.describe('NavbarController', () => {
  // Mobile viewport required: the hamburger button is `md:hidden` and the menu
  // is `md:block`, so on desktop the menu is always visible and toggle behaviour
  // is irrelevant to test.
  test.use({ viewport: { width: 375, height: 667 } });

  test.beforeEach(async ({ page }) => {
    await page.goto('/celebrity_charts');
  });

  test('menu starts hidden on mobile', async ({ page }) => {
    await expect(page.locator('[data-navbar-target="menu"]')).toHaveClass(/hidden/);
  });

  test('toggle shows the menu', async ({ page }) => {
    await page.click('[data-action="click->navbar#toggle"]');
    await expect(page.locator('[data-navbar-target="menu"]')).not.toHaveClass(/hidden/);
  });

  test('second toggle hides the menu again', async ({ page }) => {
    const menu = page.locator('[data-navbar-target="menu"]');

    await page.click('[data-action="click->navbar#toggle"]');
    await expect(menu).not.toHaveClass(/hidden/);

    await page.click('[data-action="click->navbar#toggle"]');
    await expect(menu).toHaveClass(/hidden/);
  });
});
