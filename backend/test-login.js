async function testLogin() {
    try {
        console.log('Testing Health...');
        const healthRes = await fetch('http://127.0.0.1:3000/api/health');
        console.log('Health Status:', healthRes.status);

        console.log('Testing Login...');
        const loginRes = await fetch('http://127.0.0.1:3000/admin/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                email: 'admin@wassal.com',
                password: 'password123'
            })
        });

        console.log('Login Status:', loginRes.status);
        const data = await loginRes.json();
        console.log('Login Response:', JSON.stringify(data));

    } catch (error) {
        console.error('Error:', error.message);
    }
}

testLogin();
