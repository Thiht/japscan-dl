const puppeteer = require("puppeteer");

(async () => {
  const browser = await puppeteer.launch({
    headless: false
  });

  const page = await browser.newPage();
  await page.goto("https://www.japscan.co/");
  await page.waitFor(6000);

  const ua = await browser.userAgent();
  const cookies = await page.cookies();
  const cookieString = cookies
    .filter(cookie =>
      ["session", "cf_clearance", "__cfduid"].includes(cookie.name)
    )
    .map(cookie => `${cookie.name}=${cookie.value}`)
    .join("; ");

  console.log(`ua='${ua}'; cookie='${cookieString}'`);

  await browser.close();
})();
