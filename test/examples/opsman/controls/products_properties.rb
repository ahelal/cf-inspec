describe om_products_properties do
  its(['pivotal-mysql', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
end
