export default {
  async fetch(request) {
    async function handlePostRequest(request) {
      let bodyString = await readRequestBody(request)
      
      try {
        let body = JSON.parse(bodyString);
        
        if (body.message) {
          await test(body.message.chat.id);

          if (body.message.text) {
            body.message.text = body.message.text.toLowerCase();
            body.message.text = body.message.text.replace(/@tgsdevops_bot/g,'');
          
            var paras = body.message.text.trim().split(" ");
            if (paras[0]=="/buydomain" && paras[1]!=""){
              let myRequest = new Request("https://jenkins.rpgp.cc/view/Support/job/create-domain/buildWithParameters?token=ru04xu4m4ua/6&DomainName="+paras[1]+"&ChatId="+body.message.chat.id);
              fetch(myRequest).then(function(x){
                console.log(x)
              });
            }
            
            if (paras[0]== "/changens" && paras[1]!=""){
              let requestString = "https://jenkins.rpgp.cc/view/Support/job/change-nameservers/buildWithParameters?token=ru04xu4m4ua/6&DomainName=" + paras[1]+"&ChatId="+body.message.chat.id;

              if (paras[2]!= undefined) { 
                requestString += "&NameServers="+paras[2]
              } 

              let myRequest = new Request(requestString);
                fetch(myRequest).then(function(x){
                  console.log(x)
                });
            }

            return new Response("OK");
          } else {
            return new Response("Ok");
          }
        } else {
          const init = {
            headers: {'content-type': 'application/json'},
          }
          return new Response(JSON.stringify(body),init);
        }
      }
      catch (e) {
        console.log(e)
        return new Response(e);
      }
    }

    async function readRequestBody(request) {
      const contentType = request.headers.get("content-type");
      if (contentType.includes("application/json")) {
        return JSON.stringify(await request.json());
      } else if (contentType.includes("application/text")) {
        return request.text();
      } else if (contentType.includes("text/html")) {
        return request.text();
      } else if (contentType.includes("form")) {
        const formData = await request.formData();
        const body = {};
        for (const entry of formData.entries()) {
          body[entry[0]] = entry[1];
        }
        return JSON.stringify(body);
      } else {
        // Perhaps some other type of data was submitted in the form
        // like an image, or some other binary data.
        return "a file";
      }
    }
    async function test(msg, chatid){
      let payload = {
        "method": "sendMessage",
        "chat_id": chatid,
        "text": msg,
        "parse_mode": "markdown",
        "disable_web_page_preview": true
      }
      
      const myInit = {
        method: 'POST',
        headers: {
        'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      } 
      
      let myRequest = new Request("https://api.telegram.org/bot6137223098:AAEeQiBaQ1G1Gj5pO7p9q_FVwvXViM1BMcg/", myInit);
      fetch(myRequest).then(function(x){
        console.log(x)
      });
    }
    
    if (request.method === "POST") {
      const reqBody = await handlePostRequest(request);
      const retBody = `The request body sent in was ${reqBody}`;
      return new Response(retBody);
    } else if (request.method === "GET") {
      return new Response("The request was a GET2");
    }
  },
};