// import http from 'k6/http';
// export const options = { vus: 50, duration: '5s' };
// export default function () { http.get('http://localhost:1122/ticket/1/detail/1'); }

import http from 'k6/http';
export const options = { vus: 50, duration: '30s' };
export default function () {
    http.get('https://spring-ddd-ticket-booking.onrender.com/ticket/1/detail/1');
}
