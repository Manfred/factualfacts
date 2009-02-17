ActionController::Routing::Routes.draw do |map|
  map.resources :facts

  map.root :controller => 'facts', :action => 'index'
end
