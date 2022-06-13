import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
    stages: [
        { duration: '5s', target: 1 },
        { duration: '55s', target: 1 },
        { duration: '5s', target: 20 },
        { duration: '115s', target: 20 },
        { duration: '120s', target: 200 },
        { duration: '30', target: 200 },
        { duration: '5s', target: 20 },
        { duration: '115s', target: 20 },
        { duration: '5s', target: 1 },
        { duration: '55s', target: 1 },
    ]
  };
  
export default function () {
    http.get("https://af-bcrypt-prod-eastus.azurewebsites.net/api/BCryptFunction");    
    sleep(0.1);
}