import http from 'k6/http';
import { check } from 'k6';

const domain = 'dev-bo.rpgp.cc'
export let brandIds = [];

export const options = {
  stages: [
    { target: 200, duration: '30s' },
    { target: 200, duration: '30s'},	  
    { target: 0, duration: '30s' },
  ],
};

async function getBrandAsync() {
  let res = await http.asyncRequest("GET",`https://${domain}/api/brand?Page=1&Rows=10&OrderBy=Descending&SortBy=updatedOn&status=0`);
  let json = JSON.parse(res.body);
  let brandIds = []
  for (var i = 0;i < json.items.length; i++) {
    brandIds.push(json.items[i].id);
  }
  return brandIds;
}

export function setup() {  
  let returnData = {};
  let url = `https://${domain}/api/auth`;
  let data = JSON.stringify({
    username : 'rico.lin',
    password : 'TgsP@ssw0rd'
  });

  let params = {
    headers: {
      'Content-Type': 'application/json',
      'dataType': 'json'
    }
  };
  
  const p = new Promise((resolve,reject) => {
    let res = http.post(url, data, params);
   
    if (res.status === 200) {
       console.log(JSON.stringify(res,null,2));
       resolve(console.log("loggined"));
    } else {
       reject(res);
    }
  }).then(res => {
      getBrandAsync(returnData).then(res => returnData.brandIds = res);
    }
  );
 	
  //console.log("returnData="+returnData);
  return returnData;
}

export default function (res) {
  //console.log("==brand Ids==");
  //console.log(JSON.stringify(res.brandIds));	
  let brandId = res.brandIds[Math.floor(Math.random() * 10)]	
  let promotionUrl = `https://${domain}/api/PromotionDispatch?Page=1&Rows=10&OrderBy=Descending&brandId=${brandId}`
  let brandPaymentUrl = `https://${domain}/api/brandpayment?brandId=${brandId}&page=1&rows=10&sortBy=number&OrderBy=Descending`
  console.log("url="+brandPaymentUrl);
  
  const result = http.get(brandPaymentUrl);
  check(result, {
    'http response status code is 200': result.status === 200,
  });
}

export function teardown(data) {
  let res = http.post(`https://${domain}/api/logout`);
  console.log(res);
}
