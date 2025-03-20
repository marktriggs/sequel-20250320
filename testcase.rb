$LOAD_PATH << 'lib/sequel/lib'

require 'sequel'
require 'jdbc/sqlite3'

File.unlink("testdb.db") if File.exist?("testdb.db")
DB = Sequel.connect("jdbc:sqlite:testdb.db")

DB.create_table(:table_a) do
  primary_key :a_id
end

DB.create_table(:table_b) do
  primary_key :b_id
end

DB.create_table(:join_table) do
  Integer :a_id
  Integer :b_id
end

10.times do
  DB[:table_a].insert({})
  DB[:table_b].insert({})
end


loops = 0

loop do
  loops += 1

  model_a = Class.new(Sequel::Model(:table_a)) do
  end

  model_b = Class.new(Sequel::Model(:table_b)) do
    many_to_many :model_a, :class => model_a, :left_key => :a_id, :right_key => :b_id, :join_table => :join_table
  end

  threads = []

  4.times do
    threads << Thread.new do
      model_b.eager(model_b.associations).all
    end
  end

  threads.each(&:join)

  if loops % 1000 == 0
    puts loops
  end
end
