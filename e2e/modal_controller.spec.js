const { test, expect } = require('@playwright/test');

test.use({ storageState: 'e2e/.auth-state.json' });

test.describe('ModalController', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/charts/new');
  });

  test('open removes hidden from the container', async ({ page }) => {
    const container = page.locator('#nameInstructionsModal [data-modal-target="container"]');

    await expect(container).toHaveClass(/hidden/);
    await page.click('[data-action="click->modal#open"]');
    await expect(container).not.toHaveClass(/hidden/);
  });

  test('close button adds hidden back to the container', async ({ page }) => {
    const container = page.locator('#nameInstructionsModal [data-modal-target="container"]');

    await page.click('[data-action="click->modal#open"]');
    await expect(container).not.toHaveClass(/hidden/);

    await page.click('[data-action="click->modal#close"]');
    await expect(container).toHaveClass(/hidden/);
  });

  test('clicking the backdrop closes the modal', async ({ page }) => {
    const container = page.locator('#nameInstructionsModal [data-modal-target="container"]');

    await page.click('[data-action="click->modal#open"]');

    await container.click({ position: { x: 5, y: 5 } });

    await expect(container).toHaveClass(/hidden/);
  });

  test('clicking inside the modal content does not close it', async ({ page }) => {
    const container = page.locator('#nameInstructionsModal [data-modal-target="container"]');

    await page.click('[data-action="click->modal#open"]');

    // Click the modal title inside the panel — event.target !== containerTarget
    await page.locator('#nameInstructionsModal h3').click();

    await expect(container).not.toHaveClass(/hidden/);
  });
});
