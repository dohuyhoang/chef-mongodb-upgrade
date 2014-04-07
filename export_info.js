dbName = "db_unstable_production"

conn = new Mongo();
db = conn.getDB(dbName);

collNames = db.getCollectionNames()

for (index = 0; index < collNames.length; index++) {
	var coll = db.getCollection(collNames[index]);
	var stats = coll.stats();
	print(stats.ns, stats.count, stats.size, stats.totalIndexSize);
}

printjson(sh.status())
