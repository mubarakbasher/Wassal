import axios from 'axios';

const api = axios.create({
    baseURL: (import.meta.env.VITE_API_URL || 'http://127.0.0.1:3001') + '/api/v1',
    withCredentials: true,
});

api.interceptors.request.use((config) => {
    // Fallback: if a token is in localStorage (migration period), send it as header
    const token = localStorage.getItem('admin_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_user');
            localStorage.removeItem('admin_logged_in');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default api;
