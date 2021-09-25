exports.handler = async (event) => {
  console.log(JSON.stringify(event))
  
  
  event.Records.forEach(r => {
      console.log(JSON.stringify(r))
      const msg = JSON.parse(r.body)
      console.log(`id: ${msg.id}`)
  })
   
  
  // TODO implement
  
  
  const response = {
      statusCode: 200,
      body: JSON.stringify('Hello from Lambda!'),
  };
  return response;
};
