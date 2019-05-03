describe om_deployed_products do
  its(['pivotal-mysql', 'version']) { should match(/2.4.4/) }
end
