guard 'spring', :rspec_cli => '--color --profile 5' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch('spec/factories.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml|\.jbuilder)$})      { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(v\d+/)?(.+)_(controller)\.rb$})  { |m| 
    ["spec/routing/#{m[2]}_routing_spec.rb", "spec/#{m[3]}s/#{m[2]}_#{m[3]}_spec.rb", "spec/acceptance/#{m[2]}_spec.rb", "spec/requests/#{m[2]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  
  # Capybara request specs
  watch(%r{^app/views/(v\d+/)?(.+)/.*\.(erb|haml|jbuilder)$})          { |m| ["spec/requests/#{m[2]}_spec.rb"] }
  
  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
  
end
