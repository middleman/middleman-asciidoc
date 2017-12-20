Then(/^running the Server should raise an exception$/) do
  expect{ step 'the Server is running' }.to raise_exception RuntimeError
end
