const { test, expect } = require('@playwright/test');

test.describe('AutoSubmitController', () => {
  let debounceDelay;

  test.beforeEach(async ({ page }) => {
    await page.route(/\/celebrity_charts\?/, route =>
      route.fulfill({
        status: 200,
        contentType: 'text/html; charset=utf-8',
        body: '<turbo-frame id="celebrity_charts_results"></turbo-frame>',
      })
    );

    await page.goto('/celebrity_charts');

    // Read the configured delay directly from the DOM so timing assertions
    // stay correct if the value is ever changed in the view.
    debounceDelay = await page
      .locator('form[data-auto-submit-delay-value]')
      .getAttribute('data-auto-submit-delay-value')
      .then(Number);
  });

  test('submits the form after the configured delay', async ({ page }) => {
    const input = page.locator('input[name="q"]');

    const requestPromise = page.waitForRequest(/\/celebrity_charts\?q=ada/);

    await input.pressSequentially('ada', { delay: 30 });

    const request = await requestPromise;
    expect(new URL(request.url()).searchParams.get('q')).toBe('ada');
  });

  test('does not submit before the delay expires', async ({ page }) => {
    const input = page.locator('input[name="q"]');
    const requests = [];

    page.on('request', req => {
      if (/\/celebrity_charts\?/.test(req.url())) requests.push(req.url());
    });

    await input.pressSequentially('hi', { delay: 30 });

    await page.waitForTimeout(debounceDelay / 2);

    expect(requests).toHaveLength(0);
  });

  test('debounces rapid typing into a single request', async ({ page }) => {
    const input = page.locator('input[name="q"]');
    const requests = [];

    page.on('request', req => {
      if (/\/celebrity_charts\?/.test(req.url())) requests.push(req.url());
    });

    await input.pressSequentially('hello', { delay: 30 });

    await page.waitForTimeout(debounceDelay + 200);

    expect(requests).toHaveLength(1);
    expect(new URL(requests[0]).searchParams.get('q')).toBe('hello');
  });

  test('resets the debounce timer when new input arrives mid-window', async ({ page }) => {
    const input = page.locator('input[name="q"]');
    const requestTimestamps = [];

    const requests = [];

    page.on('request', req => {
      if (/\/celebrity_charts\?/.test(req.url())) requests.push(req.url());
    });

    await input.pressSequentially('a', { delay: 0 });
    await page.waitForTimeout(Math.floor(debounceDelay * 0.6));
    await input.pressSequentially('b', { delay: 0 });

    await page.waitForTimeout(debounceDelay + 150);

    expect(requests).toHaveLength(1);
    expect(new URL(requests[0]).searchParams.get('q')).toBe('ab');
  });

  test('submits the form when a filter select changes', async ({ page }) => {
    const select = page.locator('select[name="number_type"]');

    const requestPromise = page.waitForRequest(/\/celebrity_charts\?/);

    await select.selectOption({ index: 1 });

    const request = await requestPromise;
    expect(new URL(request.url()).searchParams.get('number_type')).not.toBe('');
  });
});
