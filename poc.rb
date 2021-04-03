require 'gruff'
require 'mysql2'
require 'yaml'

db_host, db_db, db_port, db_usr, db_pwd = YAML.load_file('db_config.yaml')

client = Mysql2::Client.new(host: db_host, username: db_usr, password: db_pwd, database: db_db, port: db_port)

query = "SELECT Date_format(created, '%Y-%m-%d') AS 'time',
       Round(Avg(state), 1)             AS 'Durchschnitt',
       Round(Min(state), 1)             AS 'Minimum',
       Round(Max(state), 1)             AS 'Maximum'
FROM   states
WHERE  entity_id = 'sensor.spint_temperatur'
       AND state NOT LIKE 'un%'
GROUP  BY Date_format(created, '%Y-%m-%d')
ORDER  BY Date_format(created, '%Y-%m-%d')"

results = client.query(query)

g = Gruff::Line.new
g.title = 'Temperatur Spintchen'

labels = {}
avg = []
min = []
max = []

results.each_with_index do |row, i|
  labels[i] = row['time'].match(/\d{4}-(.*)/)[1].split('-').reverse.join('.')
  avg.push row['Durchschnitt']
  min.push row['Minimum']
  max.push row['Maximum']
end

g.labels = labels

g.data :Temperatur, avg
g.data :Min, min
g.data :Max, max

g.write('temperatur_spintchen.png')