DROP PROCEDURE MERGE_NEIGHBOUR(INTEGER)@

CREATE PROCEDURE MERGE_NEIGHBOUR(OUT status INTEGER)
	LANGUAGE SQL
	BEGIN
		DECLARE SQLSTATE CHAR(5) DEFAULT '00000';
	
		-- zip code with lowest population
		DECLARE ref_zip VARCHAR(5) DEFAULT NULL;
		-- ref_zip's population		 	    
		DECLARE ref_pop DECFLOAT DEFAULT 0;
		-- ref_zip's neighbour with lowest population 
		DECLARE n_zip VARCHAR(5) DEFAULT NULL;
		-- n_zip's population
		DECLARE n_pop DECFLOAT DEFAULT 0;
		-- list of zip merged into ref_zip
		DECLARE nm_zip VARCHAR(32000);
		-- number of iterations
		DECLARE iterations INTEGER DEFAULT 300;
		-- minimum population currently in any zipcode
		DECLARE min_pop DECFLOAT;
		
		fetch_loop:
		 	LOOP

		 	    SET ref_zip = NULL; 
		 	    SET n_zip = NULL;
		 	    SET n_pop = 0;
		 	    SET ref_pop = 0;
		 		BEGIN
				DECLARE c CURSOR FOR 
				with lowest_pop(fz, fp, fs) as(
					select zip , pop , shape from cse532.my_dup where is_m > 0 order by pop,zip fetch first 1 row only
				),
				lowest_neighbour(nz, np, ns, nm) as(
					select b.zip, b.pop, b.shape, b.m_zip from lowest_pop, cse532.my_dup as b 
						where  lowest_pop.fz <> b.zip and st_intersects(lowest_pop.fs, b.shape)
						order by b.pop, b.zip  fetch first 1 row only
				)
				select fz, fp, nz, np, nm from lowest_pop, lowest_neighbour;

				OPEN c;
				FETCH FROM c INTO ref_zip, ref_pop, n_zip, n_pop, nm_zip;
			
				IF SQLSTATE='00000' THEN
					IF n_pop>0 THEN
						UPDATE cse532.my_dup
						 	-- update population 
							SET pop = (pop + n_pop),
							-- update shape
							shape = db2gse.st_union(shape,(select shape from cse532.my_dup WHERE zip = n_zip)),
							-- add new zip to list of merged zip
							m_zip = m_zip || ',' || nm_zip,
							-- mark the row as merged
							is_m = 2
							WHERE zip = ref_zip;

						-- delete row which has been merged into another
						DELETE FROM cse532.my_dup 
							where zip = n_zip;
						SET status=1;
					ELSE
						-- if row has no neighbour mark it as '0' i.e has no neighbours
						UPDATE cse532.my_dup 
							SET is_m = 0 where zip = (select zip from cse532.my_dup where 
								is_m > 0 order by pop, zip fetch first 1 row only);
						SET status=2;
					END IF;

					close c;

					BEGIN
						DECLARE c1 CURSOR FOR SELECT pop from cse532.my_dup where is_m>0 order by pop, zip fetch first 1 row only;
						OPEN c1;
						FETCH FROM c1 INTO min_pop;
						CLOSE c1;
						IF min_pop >= 9383.82 THEN
							SET status=3;
							LEAVE fetch_loop;
						END IF;
					END;
					
					IF iterations<=0 THEN
						SET status=5;
						LEAVE fetch_loop;
					END IF;

					
				ELSE 
					SET status=6;
					-- if row has no neighbour mark it as '0' i.e has no neighbours
					UPDATE cse532.my_dup 
							SET is_m = 0 where zip = (select zip from cse532.my_dup where 
								is_m > 0 order by pop, zip fetch first 1 row only);
					-- LEAVE fetch_loop;
				END IF;
				SET iterations = iterations - 1;
				END;
			END LOOP fetch_loop;
	END@