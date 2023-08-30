import http from 'k6/http';
import { group, check } from 'k6';

const domain = 'dev-bo.rpgp.cc';
const loginData = {
  "url": `https://${domain}/api/auth`,
  "username": "rico.lin",
  "password": "TgsP@ssw0rd"
};
const params = {
    headers: {
      'Content-Type': 'application/json',
      'dataType': 'json'
    }
  };
const d = new Date();
export const options = {
  stages: [
    { target: 50, duration: '30s' },
    { target: 50, duration: '300s'},	  
    { target: 0, duration: '30s' },
  ],
  tags: {
    testid: `backoffice-api-${d.getMonth()+1}/${d.getDate()}-${d.getHours()+8}:${d.getMinutes()}`
  }
};

async function login() {
  let data = JSON.stringify({
    username : loginData.username,
    password : loginData.password
  });

  return await http.asyncRequest("POST", loginData.url, data, params);
}

async function logout() { 
  return await http.asyncRequest("POST", `https://${domain}/api/logout`);
} 

async function getBrandAsync() {
  let res = await http.asyncRequest("GET",`https://${domain}/api/brand?Page=1&Rows=10&OrderBy=Descending&SortBy=updatedOn&status=0`);

  if (res.status==200) {
    let json = JSON.parse(res.body);
    let brandIds = []
    for (var i = 0;i < json.items.length; i++) {
      brandIds.push(json.items[i].id);
    }
    return brandIds;
  } 
}

async function testMethod(brandId) {
  let promotionUrl = `https://${domain}/api/PromotionDispatch?Page=1&Rows=10&OrderBy=Descending&brandId=${brandId}`
  let brandPaymentUrl = `https://${domain}/api/brandpayment?brandId=${brandId}&page=1&rows=10&sortBy=number&OrderBy=Descending`
  //console.log("url="+brandPaymentUrl);
  const result = await http.asyncRequest("GET", brandPaymentUrl);
  return result;
}

export function setup() {  
  let returnData = {};

  login()
    .then(res => getBrandAsync())
    .then(res => {
        returnData.brandIds = res;
	return logout();
    }).then(res => console.log("logout end"));
 	
  //console.log("returnData="+JSON.stringify(returnData));
  return returnData;
}

export default function (res) {
 // console.log("==brand Ids==");
 // console.log(JSON.stringify(res));	
  let brandId = res.brandIds[Math.floor(Math.random() * 10)]	
 
  login()
  .then(res => {
          check(res, { 'http response status code is 200': res.status === 200  }); 
	  if (res.status !== 200) {
              console.log(`login:       ${res.status}-${brandId}`);
	  }
	  return testMethod(brandId);
  })
  .then(res => {
	  check(res, { 'http response status code is 200': res.status === 200  });
	  if (res.status !== 200) {
              console.log(`test method: ${res.status}-${brandId}`);
          }
	  return logout();
   })
   .then(res =>  {
	   check(res, { 'http response status code is 200': res.status === 200  });
	   if (res.status !== 200) {
              console.log(`logout:      ${res.status}-${brandId}`);
           }
   });
}
