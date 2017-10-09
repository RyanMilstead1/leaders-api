collection @leaders

node do |leader|
  partial('v1/leaders/show', :object => leader)
end
