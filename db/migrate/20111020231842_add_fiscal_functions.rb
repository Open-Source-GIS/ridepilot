class AddFiscalFunctions < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION fiscal_year(timestamp without time zone)
        RETURNS integer AS
      $BODY$ 
      DECLARE
        date ALIAS FOR $1;
        month integer;
      BEGIN
      month := date_part('month', date);
      return date_part('year', date) + case when month < 7 then 0 else 1 end ;
      END 
      $BODY$
        LANGUAGE plpgsql IMMUTABLE
        COST 100;
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION fiscal_month(timestamp without time zone)
        RETURNS integer AS
      $BODY$ 
      DECLARE
        date ALIAS FOR $1;
        month integer;
      BEGIN
      month := date_part('month', date);
      return 1 + (month + 5) % 12;
      END 
      $BODY$
        LANGUAGE plpgsql IMMUTABLE
        COST 100;
    SQL
  end

  def self.down
    execute 'DROP FUNCTION fiscal_month(timestamp without time zone);'
    execute 'DROP FUNCTION fiscal_year(timestamp without time zone);'
  end
end
