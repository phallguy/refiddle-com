# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.create( name: "Example" ) unless User.where( name: "Example" ).first

example_user = User.find( "example" )

unless test_sample = example_user.refiddles.where( slug: "red-green-corpus-test" ).first
  example_user.refiddles.create! title: "Red Green Corpus Test", regex: "/m.* mouse/gi", tags: "test,example", locked: true, share: true, corpus_text: <<-eos
Corpus tests allow you to unit test your regular expressions using a typical red => green development flow.

Test sections are marked indicating if the following lines should (#+) or should not (#-) match the regex pattern. Blank lines are ignored.    
    
#+ The following lines will be tested. If they match, they'll be hilighted in green, otherwise they'll be red
mickey mouse.
Mighty Mouse.

#- Nothing below this line should match, if it does it'll show up red
danger mouse

#+ You can switch back to positive matching
Miney mouse

#- And back again. 
Mikes mouse burgers <- Oops, shouldn't match but it does
eos
end