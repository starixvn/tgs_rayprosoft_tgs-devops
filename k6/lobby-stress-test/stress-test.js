import http from 'k6/http';
import { group, check } from 'k6';

const domain = 'stg-t15.rpgp.cc';

const pathArray = [
  "esports",
  "sports",
  "live",
  "chess",
  "slots",
  "electron",
  "fish",
  "cockfight",
  "promotion",
  "vip"
]
const d = new Date();
export const options = {
  stages: [
    { target: 50, duration: '30s' },
    { target: 50, duration: '300s'},	  
    { target: 0, duration: '30s' },
    
    { target: 100, duration: '60s' },
    { target: 300, duration: '60s'},	  
    { target: 600, duration: '60s'}
    { target: 0, duration: '30s' },
    
  ],
  tags: {
    testid: `t15-${d.getMonth()+1}/${d.getDate()}-${d.getHours()+8}:${d.getMinutes()}`
  }
};

export default function () {
  pathArray.forEach ((path)=> {
    const res = http.get(`https://${domain}/${path}`);
    check(res, { 'http response status code is 200': res.status === 200  }); 
  });
}
