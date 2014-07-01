//
//  BZObjectStoreMigrationQueryBuilder.m
//  BZObjectStore
//
//  Created by SHIMADATAKESHI on 2014/06/22.
//  Copyright (c) 2014年 BONZOO INC. All rights reserved.
//

#import "BZObjectStoreMigrationQueryBuilder.h"
#import "BZObjectStoreSQLiteColumnModel.h"
#import "BZObjectStoreMigrationTable.h"
#import "BZObjectStoreQueryBuilder.h"

@implementation BZObjectStoreMigrationQueryBuilder

#pragma mark migration

+ (NSString*)selectInsertStatementWithToMigrationTable:(BZObjectStoreMigrationTable*)toMigrationTable fromMigrationTable:(BZObjectStoreMigrationTable*)fromMigrationTable
{
    NSMutableString *sqlInsert = [NSMutableString string];
    [sqlInsert appendString:@"INSERT INTO "];
    [sqlInsert appendString:toMigrationTable.temporaryTableName];
    [sqlInsert appendString:@"("];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in fromMigrationTable.migrateColumns.allValues) {
        [sqlInsert appendString:sqliteColumn.columnName];
        [sqlInsert appendString:@","];
    }
    [sqlInsert appendString:@"__createdAt__"];
    [sqlInsert appendString:@",__updatedAt__"];
    [sqlInsert appendString:@")"];
    
    NSMutableString *sqlSelect = [NSMutableString string];
    [sqlSelect appendString:@" "];
    [sqlSelect appendString:@"SELECT "];
    for (BZObjectStoreSQLiteColumnModel *sqliteColumn in fromMigrationTable.migrateColumns.allValues) {
        [sqlSelect appendString:sqliteColumn.columnName];
        [sqlSelect appendString:@","];
    }
    [sqlSelect appendString:@"__createdAt__"];
    [sqlSelect appendString:@",__updatedAt__"];
    [sqlSelect appendString:@" "];
    [sqlSelect appendString:@"FROM"];
    [sqlSelect appendString:@" "];
    [sqlSelect appendString:fromMigrationTable.tableName];
    
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:sqlInsert];
    [sql appendString:sqlSelect];
    return [NSString stringWithString:sql];
}

+ (NSString*)dropTableStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    NSString *tableName = migrationTable.temporaryTableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"DROP TABLE "];
    [sql appendString:tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)deleteFromStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    NSString *tableName = migrationTable.temporaryTableName;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@",tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)createTableStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    return [BZObjectStoreQueryBuilder createTableStatement:migrationTable.temporaryTableName fullTextSearch3:migrationTable.fullTextSearch3 fullTextSearch4:migrationTable.fullTextSearch4 sqliteColumns:migrationTable.columns.allValues];
}

+ (NSString*)createTemporaryUniqueIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    return [BZObjectStoreQueryBuilder createUniqueIndexStatement:migrationTable.temporaryTableName sqliteColumns:migrationTable.identicalColumns.allValues];
}

+ (NSString*)createUniqueIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    return [BZObjectStoreQueryBuilder createUniqueIndexStatement:migrationTable.temporaryTableName sqliteColumns:migrationTable.identicalColumns.allValues];
}

+ (NSString*)alterTableRenameStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"ALTER TABLE"];
    [sql appendString:@" "];
    [sql appendString:migrationTable.temporaryTableName];
    [sql appendString:@" "];
    [sql appendString:@"RENAME TO"];
    [sql appendString:@" "];
    [sql appendString:migrationTable.tableName];
    return [NSString stringWithString:sql];
}

+ (NSString*)dropIndexStatementWithMigrationTable:(BZObjectStoreMigrationTable*)migrationTable
{
    NSString *tableName = migrationTable.temporaryTableName;
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:@"DROP INDEX IF EXISTS "];
    [sql appendString:[BZObjectStoreQueryBuilder uniqueIndexNameWithTableName:tableName]];
    return [NSString stringWithString:sql];
}


@end