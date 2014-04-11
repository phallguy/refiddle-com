require 'nokogiri'


task :import_old_db => :environment do

  path = File.join( Rails.root, "db", "tables", "db.xml" )
  puts "Reading old db from #{path}..."

  db = Nokogiri::XML( open( path ) )

  puts "Building tables..."

  tables = {}
  db.xpath("//table_data").each do |child|
    next unless child.is_a? Nokogiri::XML::Element
    tables[child["name"]] = table = []

    child.children.each do |row|
      next unless row.is_a? Nokogiri::XML::Element
      record = {}
      table << record

      row.children.each do |field|
        next unless field.is_a? Nokogiri::XML::Element 
        val = field.text
        val = nil if field["xsi:nil"].to_bool
        record[field["name"]] = val
      end
    end
  end


  puts "Importing users..."
  User.all.destroy_all
  users           = tables["users"]
  authentications = tables["authentications"]

  users.each do |user|
    authentication = authentications.find{ |a| a["user_id"] == user["id"] }
    next unless authentication

    unless account = User.where( uid: authentication["uid"] ).first
      account = User.create! name: user["name"], _slugs: [user["nickname"].try(:parameterize)], provider: authentication["provider"],
                              uid: authentication["uid"], email: user["email"], time_zone: user["time_zone"]
    end

    user["account"] = account
  end

  User.where( email: "paul.xheo@gmail.com" ).each{ |u| u.add_role! :admin }

  fiddles  = tables["fiddles"]
  taggings = tables["taggings"]
  tags     = tables["tags"]

  fiddles.sort_by!{|f| f["created_at"] || "" }

  puts "Importing fiddles..."
  Refiddle.all.destroy_all

  fiddles.each do |fiddle|
    short_code = ( 1300 + fiddle["id"].to_i ).to_s(36)

    unless refiddle = Refiddle.where( short_code: short_code ).first
      refiddle = Refiddle.new title: fiddle["title"], description: fiddle["description"], short_code: short_code,
           flavor: Refiddle::FLAVORS.keys[fiddle["flavor"].to_i], share: fiddle["share"] == "1", locked: fiddle["locked"] == "1",
           regex: fiddle["pattern"], corpus_text: fiddle["corpus_text"], replace_text: fiddle["replace_text"],
           forks_count: fiddle["forks_count"].to_i
      
      if fiddle["owner_id"] &&  user = users.find{|u| u["id"] == fiddle["owner_id"] }
        refiddle.user = user["account"]
      end

      if refiddle.locked && ! refiddle.user
        refiddle.locked = false
      end

      fiddle["refiddle"] = refiddle

      if id = fiddle["forked_from_id"]
        if forked = fiddles.find{|f| f["id"] == id }        
          refiddle.forked_from = forked["refiddle"]
        end
      end

      refiddle.tags = taggings.select{|t| t["taggable_id"] == fiddle["id"] }.reduce([]) do |fiddle_tags,tagging|
        if tag = tags.find{|t| t["id"] == tagging["tag_id"]}
          fiddle_tags << tag["name"]
        end
        fiddle_tags
      end

      begin
        refiddle.save!
      rescue StandardError => e
        case e.message 
        when /Make it your own/ then next
        when /Something doesn't look quite right/ then next
        else
          puts e
          puts refiddle
        end
      end
    end
  end

  # Refiddle.where( "revisions.corpus_text" => /darth@vader.com/ ).destroy
  # Refiddle.where( "revisions.corpus_text" => /The quick #brown fox jumps over the #lazy dog/ ).destroy


end
