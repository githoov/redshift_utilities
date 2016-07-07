/*
These are example variant architectures of the
same event-data table. These are purely for
illustrative purposes. You will need your own create
table statements.
*/

/* simple sort */
create table event_tmp1 (
	event_id bigint encode mostly16
	, agent character varying(65535) encode lzo
	, referrer character varying(65535) encode lzo
	, user_id integer encode mostly8
	, version character varying(100) encode bytedict
	, created_at timestamp without time zone encode delta
	, ip_address character varying(100) encode lzo
	, event_type character varying(200) encode bytedict
	, license_slug character varying(200) encode lzo
	, recipient character varying(200) encode lzo
	, killed boolean encode runlength
	, source_url character varying(2000) encode lzo
	, source character varying(2000) encode lzo
	, uri character varying(65535) encode lzo
	, errors character varying(2000) encode lzo
	, successful boolean encode runlength
	, runtime numeric(18,0) encode delta32k
	, sent boolean encode runlength
	, browser_instance_id character varying(100) encode lzo
	, user_agent character varying(65535) encode lzo
	, response_status integer encode mostly8
	, elapsed_seconds real encode runlength
	, base_route character varying(256) encode bytedict
	, api_version real encode bytedict
	, sdk_operation_id character varying(128) encode lzo)
diststyle even
sortkey(created_at);

/* compound sort */
create table event_tmp2 (
	event_id bigint encode mostly16
	, agent character varying(65535) encode lzo
	, referrer character varying(65535) encode lzo
	, user_id integer encode mostly8
	, version character varying(100) encode bytedict
	, created_at timestamp without time zone encode delta
	, ip_address character varying(100) encode lzo
	, event_type character varying(200) encode bytedict
	, license_slug character varying(200) encode lzo
	, recipient character varying(200) encode lzo
	, killed boolean encode runlength
	, source_url character varying(2000) encode lzo
	, source character varying(2000) encode lzo
	, uri character varying(65535) encode lzo
	, errors character varying(2000) encode lzo
	, successful boolean encode runlength
	, runtime numeric(18,0) encode delta32k
	, sent boolean encode runlength
	, browser_instance_id character varying(100) encode lzo
	, user_agent character varying(65535) encode lzo
	, response_status integer encode mostly8
	, elapsed_seconds real encode runlength
	, base_route character varying(256) encode bytedict
	, api_version real encode bytedict
	, sdk_operation_id character varying(128) encode lzo)
diststyle even
sortkey(created_at, user_id, license_slug);

/* interleaved sort */
create table event_tmp3 (
	event_id bigint encode mostly16
	, agent character varying(65535) encode lzo
	, referrer character varying(65535) encode lzo
	, user_id integer encode mostly8
	, version character varying(100) encode bytedict
	, created_at timestamp without time zone encode delta
	, ip_address character varying(100) encode lzo
	, event_type character varying(200) encode bytedict
	, license_slug character varying(200) encode lzo
	, recipient character varying(200) encode lzo
	, killed boolean encode runlength
	, source_url character varying(2000) encode lzo
	, source character varying(2000) encode lzo
	, uri character varying(65535) encode lzo
	, errors character varying(2000) encode lzo
	, successful boolean encode runlength
	, runtime numeric(18,0) encode delta32k
	, sent boolean encode runlength
	, browser_instance_id character varying(100) encode lzo
	, user_agent character varying(65535) encode lzo
	, response_status integer encode mostly8
	, elapsed_seconds real encode runlength
	, base_route character varying(256) encode bytedict
	, api_version real encode bytedict
	, sdk_operation_id character varying(128) encode lzo)
diststyle even
interleaved sortkey(created_at, user_id, license_slug);

/* interleaved sort distributing on license_slug */
create table event_tmp4 (
	event_id bigint encode mostly16
	, agent character varying(65535) encode lzo
	, referrer character varying(65535) encode lzo
	, user_id integer encode mostly8
	, version character varying(100) encode bytedict
	, created_at timestamp without time zone encode delta
	, ip_address character varying(100) encode lzo
	, event_type character varying(200) encode bytedict
	, license_slug character varying(200) encode lzo
	, recipient character varying(200) encode lzo
	, killed boolean encode runlength
	, source_url character varying(2000) encode lzo
	, source character varying(2000) encode lzo
	, uri character varying(65535) encode lzo
	, errors character varying(2000) encode lzo
	, successful boolean encode runlength
	, runtime numeric(18,0) encode delta32k
	, sent boolean encode runlength
	, browser_instance_id character varying(100) encode lzo
	, user_agent character varying(65535) encode lzo
	, response_status integer encode mostly8
	, elapsed_seconds real encode runlength
	, base_route character varying(256) encode bytedict
	, api_version real encode bytedict
	, sdk_operation_id character varying(128) encode lzo)
distkey(license_slug)
interleaved sortkey(created_at, user_id, license_slug);


/* compound sort distributing on license_slug */
create table event_tmp5 (
	event_id bigint encode mostly16
	, agent character varying(65535) encode lzo
	, referrer character varying(65535) encode lzo
	, user_id integer encode mostly8
	, version character varying(100) encode bytedict
	, created_at timestamp without time zone encode delta
	, ip_address character varying(100) encode lzo
	, event_type character varying(200) encode bytedict
	, license_slug character varying(200) encode lzo
	, recipient character varying(200) encode lzo
	, killed boolean encode runlength
	, source_url character varying(2000) encode lzo
	, source character varying(2000) encode lzo
	, uri character varying(65535) encode lzo
	, errors character varying(2000) encode lzo
	, successful boolean encode runlength
	, runtime numeric(18,0) encode delta32k
	, sent boolean encode runlength
	, browser_instance_id character varying(100) encode lzo
	, user_agent character varying(65535) encode lzo
	, response_status integer encode mostly8
	, elapsed_seconds real encode runlength
	, base_route character varying(256) encode bytedict
	, api_version real encode bytedict
	, sdk_operation_id character varying(128) encode lzo)
distkey(license_slug)
sortkey(created_at, user_id, license_slug);