import http from 'k6/http';
export const options = { vus: 50, duration: '5s' };
export default function () { http.get('http://localhost:1122/ticket/1/detail/1'); }
