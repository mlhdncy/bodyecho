const https = require('https');

const CLIENT_ID = 'f7a036bce03d407082f0051ed0c8639a';
const CLIENT_SECRET = '7d1ca9b45a964c3095f04a0cdec04ee3';

function post(url, data, headers) {
    return new Promise((resolve, reject) => {
        const urlObj = new URL(url);
        const options = {
            hostname: urlObj.hostname,
            path: urlObj.pathname + urlObj.search,
            method: 'POST',
            headers: headers
        };

        const req = https.request(options, res => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => resolve({ statusCode: res.statusCode, body: body }));
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

function get(url, headers) {
    return new Promise((resolve, reject) => {
        const urlObj = new URL(url);
        const options = {
            hostname: urlObj.hostname,
            path: urlObj.pathname + urlObj.search,
            method: 'GET',
            headers: headers
        };

        const req = https.request(options, res => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => resolve({ statusCode: res.statusCode, body: body }));
        });

        req.on('error', reject);
        req.end();
    });
}

async function test() {
    console.log("Testing FatSecret API...");

    // 1. Get Token
    const tokenUrl = 'https://oauth.fatsecret.com/connect/token';
    const auth = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');
    const headers = {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded'
    };
    const data = 'grant_type=client_credentials&scope=basic';

    try {
        console.log(`Requesting token from ${tokenUrl}...`);
        const tokenRes = await post(tokenUrl, data, headers);
        console.log(`Token Response Status: ${tokenRes.statusCode}`);
        console.log(`Token Response Body: ${tokenRes.body}`);

        if (tokenRes.statusCode !== 200) {
            console.log("Failed to get token.");
            return;
        }

        const token = JSON.parse(tokenRes.body).access_token;
        console.log("Token obtained successfully.");

        // 2. Search Food
        const searchUrl = `https://platform.fatsecret.com/rest/server.api?method=foods.search&search_expression=apple&format=json`;
        const searchHeaders = {
            'Authorization': `Bearer ${token}`
        };

        console.log(`Searching for 'apple' at ${searchUrl}...`);
        const searchRes = await get(searchUrl, searchHeaders);
        console.log(`Search Response Status: ${searchRes.statusCode}`);
        console.log(`Search Response Body: ${searchRes.body.substring(0, 500)}`);

    } catch (e) {
        console.error("Exception:", e);
    }
}

test();
