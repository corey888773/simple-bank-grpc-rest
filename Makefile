DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable

postgres:
	docker run --name postgres15.4 --network golang-course -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=simple_bank -d postgres:15.4-alpine

dbstart:
	docker start postgres15.4

createdb:
	docker exec -it postgres15.4 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres15.4 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down
	
migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1
	
sqlc:
	sqlc generate

psql:
	docker exec -it postgres15.4 psql -U root simple_bank

test:
	go test -v -cover -short ./api/...
	go test -v -cover -short ./gapi/...
	go test -v -cover -short ./db/...
	
 
server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store_mock.go github.com/corey888773/golang-course/db/sqlc Store

dbdocs:
	dbdocs build doc/db.dbml

dbschema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

protoc:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto
	statik -src=./doc/swagger -dest=./doc/

evans:
	evans --host localhost --port 9000 --path ./proto/ --proto service_simple_bank.proto

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine

.PHONY:
	postgres createdb dropdb migrateup migrateup1 migratedown migratedown1 sqlc dbstart test psql server mock dbdocs dbschema protoc evans redis