module.exports = async function globalTeardown(config) {
  const { baseURL } = config.projects[0].use;
  const response = await fetch(`${baseURL}/test/sign_in`, { method: 'DELETE' });
  if (!response.ok) throw new Error(`Teardown failed: ${response.status}`);
};
