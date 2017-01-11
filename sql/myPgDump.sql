CREATE TABLE auth_group (
    id integer NOT NULL primary key autoincrement,
    name character varying(80) NOT NULL
);

CREATE TABLE auth_group_permissions (
    id integer NOT NULL  primary key autoincrement,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);

CREATE TABLE auth_permission (
    id integer NOT NULL primary key autoincrement,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);

CREATE TABLE auth_user (
    id integer NOT NULL primary key autoincrement,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);

CREATE TABLE auth_user_groups (
    id integer NOT NULL primary key autoincrement,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);

CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL primary key autoincrement,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);

CREATE TABLE django_admin_log (
    id integer NOT NULL primary key autoincrement,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);

CREATE TABLE django_content_type (
    id integer NOT NULL primary key autoincrement,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);

CREATE TABLE django_migrations (
    id integer NOT NULL primary key autoincrement,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);

CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);

CREATE TABLE trip_fund_raiser (
    id integer NOT NULL primary key autoincrement,
    description character varying(200) NOT NULL,
    profit numeric(6,2),
    profit_percentage numeric(5,2),
    fund_raiser_type_id integer NOT NULL,
    trip_id integer NOT NULL,
    fund_raiser_date date NOT NULL
);

CREATE TABLE trip_fund_raiser_item (
    id integer NOT NULL primary key autoincrement,
    description character varying(50) NOT NULL,
    display_order integer NOT NULL,
    cost numeric(6,2),
    profit numeric(6,2),
    profit_percentage integer,
    fund_raiser_id integer NOT NULL
);

CREATE TABLE trip_student_fund_raiser (
    id integer NOT NULL primary key autoincrement,
    quantity_sold integer NOT NULL,
    fund_raiser_id integer NOT NULL,
    trip_commitment_id integer NOT NULL
);




CREATE TABLE trip_fund_raiser_profit (
    id integer NOT NULL primary key autoincrement,
    profit numeric(6,2) NOT NULL,
    date_entered timestamp with time zone NOT NULL,
    trip_commitment_id integer NOT NULL,
    fund_raiser_id integer NOT NULL
);



CREATE VIEW trip_fund_raiser_profit_vw AS
 SELECT frp.trip_commitment_id,
    fr.id,
    fr.description AS fund_raiser_description,
    COALESCE(sum(COALESCE(frp.profit, 0.00)), 0.00) AS total_profit
   FROM (trip_fund_raiser fr
     JOIN trip_fund_raiser_profit frp ON ((fr.id = frp.fund_raiser_id)))
  GROUP BY frp.trip_commitment_id, fr.id, fr.description;


CREATE VIEW trip_all_fund_raiser_profit_vw AS
 SELECT trip_fund_raiser_item_profit_vw.trip_commitment_id,
    'Item'::text AS fund_raiser_type,
    trip_fund_raiser_item_profit_vw.fund_raiser_id,
    trip_fund_raiser_item_profit_vw.fund_raiser_description,
    trip_fund_raiser_item_profit_vw.total_profit
   FROM trip_fund_raiser_item_profit_vw
UNION
 SELECT trip_fund_raiser_profit_vw.trip_commitment_id,
    'Single'::text AS fund_raiser_type,
    trip_fund_raiser_profit_vw.id AS fund_raiser_id,
    trip_fund_raiser_profit_vw.fund_raiser_description,
    trip_fund_raiser_profit_vw.total_profit
   FROM trip_fund_raiser_profit_vw;



CREATE TABLE trip_student (
    id integer NOT NULL primary key autoincrement,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email_1 character varying(75),
    phone_1 character varying(15),
    phone_2 character varying(15),
    svid character varying(10),
    email_2 character varying(75)
);



CREATE TABLE trip_trip_commitment (
    id integer NOT NULL primary key autoincrement,
    student_grade integer NOT NULL,
    period character varying(2),
    going_on_trip character varying(1) NOT NULL,
    purchase_insurance boolean NOT NULL,
    trip_id integer NOT NULL,
    student_id integer NOT NULL
);



CREATE VIEW trip_trip_commitment_vw AS
 SELECT s.id,
    tc.id AS trip_commitment_id,
    s.first_name,
    s.last_name,
    s.email_1,
    s.email_2,
    s.phone_1,
    s.phone_2,
    s.svid,
    tc.student_grade,
    tc.period,
    tc.going_on_trip,
    tc.purchase_insurance,
    tc.trip_id
   FROM (trip_student s
     JOIN trip_trip_commitment tc ON ((s.id = tc.student_id)));



CREATE VIEW trip_fund_raiser_detail_vw AS
 SELECT frp.id AS fund_raiser_profit_id,
    tc.trip_commitment_id,
    frp.fund_raiser_id,
    tc.first_name,
    tc.last_name,
    frp.profit,
    frp.date_entered,
    tfr.description AS fund_raiser_description,
    tfr.profit_percentage
   FROM ((trip_trip_commitment_vw tc
     JOIN trip_fund_raiser_profit frp ON ((tc.trip_commitment_id = frp.trip_commitment_id)))
     JOIN trip_fund_raiser tfr ON ((frp.fund_raiser_id = tfr.id)));



CREATE SEQUENCE trip_fund_raiser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE VIEW trip_fund_raiser_item_detail_vw AS
 SELECT tc.trip_commitment_id,
    fri.id AS fund_raiser_item_id,
    sfr.id AS student_fund_raiser_id,
    fr.id AS fund_raiser_id,
    tc.first_name,
    tc.last_name,
    fri.description AS item_description,
    fri.display_order,
    fri.cost,
    (fri.cost * (sfr.quantity_sold)::numeric) AS sub_total,
    fri.profit,
    fri.profit_percentage,
    (fri.profit * (sfr.quantity_sold)::numeric) AS profit_total,
    ((fri.cost * (sfr.quantity_sold)::numeric) * (fri.profit_percentage)::numeric) AS profit_percentage_total,
    fr.description AS fund_raiser,
    sfr.quantity_sold
   FROM (((trip_fund_raiser_item fri
     JOIN trip_fund_raiser fr ON ((fri.fund_raiser_id = fr.id)))
     JOIN trip_student_fund_raiser sfr ON ((fri.id = sfr.fund_raiser_id)))
     JOIN trip_trip_commitment_vw tc ON ((sfr.trip_commitment_id = tc.trip_commitment_id)));



CREATE SEQUENCE trip_fund_raiser_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE SEQUENCE trip_fund_raiser_profit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE TABLE trip_fund_raiser_type (
    id integer NOT NULL primary key autoincrement,
    description character varying(75) NOT NULL,
    super_group character varying(75) NOT NULL
);



CREATE SEQUENCE trip_fund_raiser_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE TABLE trip_payment (
    id integer NOT NULL primary key autoincrement,
    payment_date date,
    payment_amount numeric(6,2) NOT NULL,
    check_number character varying(20) NOT NULL,
    deposit_date date,
    trip_commitment_id integer NOT NULL
);



CREATE SEQUENCE trip_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE trip_student_fund_rasier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE SEQUENCE trip_student_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE VIEW trip_total_fund_raiser_profit_vw AS
 SELECT tc.trip_commitment_id,
    (sum(COALESCE(frp.total_profit, 0.00)) + sum(COALESCE(frip.total_profit, 0.00))) AS profit
   FROM ((trip_trip_commitment_vw tc
     LEFT JOIN trip_fund_raiser_profit_vw frp ON ((tc.trip_commitment_id = frp.trip_commitment_id)))
     LEFT JOIN trip_fund_raiser_item_profit_vw frip ON ((tc.trip_commitment_id = frip.trip_commitment_id)))
  GROUP BY tc.trip_commitment_id;


ALTER TABLE trip_total_fund_raiser_profit_vw OWNER TO postgres;


CREATE TABLE trip_trip (
    id integer NOT NULL primary key autoincrement,
    description character varying(200) NOT NULL,
    trip_cost numeric(6,2) NOT NULL,
    insurance_cost numeric(6,2) NOT NULL,
    trip_company character varying(200),
    trip_company_contact character varying(200),
    trip_company_phone character varying(15),
    trip_company_email character varying(75),
    trip_coordinator character varying(200),
    trip_coordinator_email character varying(75),
    current_trip boolean NOT NULL,
    school_year smallint,
    trip_end_date date,
    trip_start_date date
);


CREATE TABLE trip_trip_payment_date (
    id integer NOT NULL primary key autoincrement,
    payment_date date NOT NULL,
    payment_amount numeric(6,2),
    final_payment boolean,
    trip_id integer NOT NULL
);



CREATE VIEW trip_trip_current_payment_due AS
 SELECT tpd.trip_id,
    trip.current_trip,
    maxtpd.current_payment_date,
        CASE
            WHEN (maxtpd.final_payment = true) THEN trip.trip_cost
            ELSE tpd.payment_due
        END AS current_amount_due
   FROM ((trip_trip trip
     JOIN ( SELECT trip_trip_payment_date.trip_id,
            sum(COALESCE(trip_trip_payment_date.payment_amount, 0.00)) AS payment_due
           FROM trip_trip_payment_date
          WHERE (trip_trip_payment_date.payment_date <= ('now'::text)::date)
          GROUP BY trip_trip_payment_date.trip_id) tpd ON ((trip.id = tpd.trip_id)))
     JOIN ( SELECT trip_trip_payment_date.trip_id,
            trip_trip_payment_date.payment_date AS current_payment_date,
            trip_trip_payment_date.final_payment
           FROM trip_trip_payment_date
          WHERE ((trip_trip_payment_date.trip_id, trip_trip_payment_date.payment_date) IN ( SELECT trip_trip_payment_date_1.trip_id,
                    max(trip_trip_payment_date_1.payment_date) AS current_payment_date
                   FROM trip_trip_payment_date trip_trip_payment_date_1
                  WHERE (trip_trip_payment_date_1.payment_date <= ('now'::text)::date)
                  GROUP BY trip_trip_payment_date_1.trip_id))) maxtpd ON ((trip.id = maxtpd.trip_id)));



CREATE VIEW trip_trip_commitment_dashboard_vw AS
 SELECT tc.id,
    tc.trip_commitment_id,
    (((tc.last_name)::text || ', '::text) || (tc.first_name)::text) AS full_name,
    tc.student_grade,
    tc.period,
    tc.going_on_trip,
    tc.purchase_insurance,
    tc.email_1,
    tc.email_2,
    tc.phone_1,
    tc.phone_2,
    trip.description AS trip_description,
    trip.trip_cost,
    trip.insurance_cost,
    trip.current_trip,
    COALESCE(trip_payment.total_payment, 0.00) AS total_payment,
    COALESCE(frp.profit, (0)::numeric) AS total_fund_raiser_profit,
    cpd.current_amount_due,
    cpd.current_payment_date,
    ((cpd.current_amount_due - COALESCE(trip_payment.total_payment, (0)::numeric)) - COALESCE(frp.profit, (0)::numeric)) AS current_payment_due,
    ((trip.trip_cost - COALESCE(trip_payment.total_payment, (0)::numeric)) - COALESCE(frp.profit, (0)::numeric)) AS trip_balance,
        CASE
            WHEN (((cpd.current_amount_due - COALESCE(trip_payment.total_payment, (0)::numeric)) - COALESCE(frp.profit, (0)::numeric)) <= (0)::numeric) THEN 'OK'::text
            ELSE 'LOW'::text
        END AS account_up_to_date
   FROM ((((trip_trip_commitment_vw tc
     JOIN trip_trip trip ON ((tc.trip_id = trip.id)))
     JOIN trip_trip_current_payment_due cpd ON ((tc.trip_id = cpd.trip_id)))
     LEFT JOIN ( SELECT x.trip_commitment_id,
            sum(x.payment_amount) AS total_payment
           FROM trip_payment x
          GROUP BY x.trip_commitment_id) trip_payment ON ((tc.trip_commitment_id = trip_payment.trip_commitment_id)))
     LEFT JOIN trip_total_fund_raiser_profit_vw frp ON ((tc.trip_commitment_id = frp.trip_commitment_id)))
  WHERE (trip.current_trip = true);



CREATE SEQUENCE trip_trip_commitment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE SEQUENCE trip_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



CREATE SEQUENCE trip_trip_payment_date_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;





INSERT INTO auth_permission VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO auth_permission VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO auth_permission VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO auth_permission VALUES (4, 'Can add group', 2, 'add_group');
INSERT INTO auth_permission VALUES (5, 'Can change group', 2, 'change_group');
INSERT INTO auth_permission VALUES (6, 'Can delete group', 2, 'delete_group');
INSERT INTO auth_permission VALUES (7, 'Can add user', 3, 'add_user');
INSERT INTO auth_permission VALUES (8, 'Can change user', 3, 'change_user');
INSERT INTO auth_permission VALUES (9, 'Can delete user', 3, 'delete_user');
INSERT INTO auth_permission VALUES (10, 'Can add permission', 4, 'add_permission');
INSERT INTO auth_permission VALUES (11, 'Can change permission', 4, 'change_permission');
INSERT INTO auth_permission VALUES (12, 'Can delete permission', 4, 'delete_permission');
INSERT INTO auth_permission VALUES (13, 'Can add content type', 5, 'add_contenttype');
INSERT INTO auth_permission VALUES (14, 'Can change content type', 5, 'change_contenttype');
INSERT INTO auth_permission VALUES (15, 'Can delete content type', 5, 'delete_contenttype');
INSERT INTO auth_permission VALUES (16, 'Can add session', 6, 'add_session');
INSERT INTO auth_permission VALUES (17, 'Can change session', 6, 'change_session');
INSERT INTO auth_permission VALUES (18, 'Can delete session', 6, 'delete_session');
INSERT INTO auth_permission VALUES (19, 'Can add fund_ raiser', 7, 'add_fund_raiser');
INSERT INTO auth_permission VALUES (20, 'Can change fund_ raiser', 7, 'change_fund_raiser');
INSERT INTO auth_permission VALUES (21, 'Can delete fund_ raiser', 7, 'delete_fund_raiser');
INSERT INTO auth_permission VALUES (22, 'Can add fund_ raiser_ type', 8, 'add_fund_raiser_type');
INSERT INTO auth_permission VALUES (23, 'Can change fund_ raiser_ type', 8, 'change_fund_raiser_type');
INSERT INTO auth_permission VALUES (24, 'Can delete fund_ raiser_ type', 8, 'delete_fund_raiser_type');
INSERT INTO auth_permission VALUES (25, 'Can add trip', 9, 'add_trip');
INSERT INTO auth_permission VALUES (26, 'Can change trip', 9, 'change_trip');
INSERT INTO auth_permission VALUES (27, 'Can delete trip', 9, 'delete_trip');
INSERT INTO auth_permission VALUES (28, 'Can add trip_ commitment', 10, 'add_trip_commitment');
INSERT INTO auth_permission VALUES (29, 'Can change trip_ commitment', 10, 'change_trip_commitment');
INSERT INTO auth_permission VALUES (30, 'Can delete trip_ commitment', 10, 'delete_trip_commitment');
INSERT INTO auth_permission VALUES (31, 'Can add Trip Payment Date', 11, 'add_trip_payment_date');
INSERT INTO auth_permission VALUES (32, 'Can change Trip Payment Date', 11, 'change_trip_payment_date');
INSERT INTO auth_permission VALUES (33, 'Can delete Trip Payment Date', 11, 'delete_trip_payment_date');
INSERT INTO auth_permission VALUES (34, 'Can add Fund_Raiser_Item', 12, 'add_fund_raiser_item');
INSERT INTO auth_permission VALUES (35, 'Can change Fund_Raiser_Item', 12, 'change_fund_raiser_item');
INSERT INTO auth_permission VALUES (36, 'Can delete Fund_Raiser_Item', 12, 'delete_fund_raiser_item');
INSERT INTO auth_permission VALUES (37, 'Can add payment', 13, 'add_payment');
INSERT INTO auth_permission VALUES (38, 'Can change payment', 13, 'change_payment');
INSERT INTO auth_permission VALUES (39, 'Can delete payment', 13, 'delete_payment');
INSERT INTO auth_permission VALUES (40, 'Can add student_ fund_ rasier', 14, 'add_student_fund_rasier');
INSERT INTO auth_permission VALUES (41, 'Can change student_ fund_ rasier', 14, 'change_student_fund_rasier');
INSERT INTO auth_permission VALUES (42, 'Can delete student_ fund_ rasier', 14, 'delete_student_fund_rasier');
INSERT INTO auth_permission VALUES (43, 'Can add student_ fund_ raiser', 14, 'add_student_fund_raiser');
INSERT INTO auth_permission VALUES (44, 'Can change student_ fund_ raiser', 14, 'change_student_fund_raiser');
INSERT INTO auth_permission VALUES (45, 'Can delete student_ fund_ raiser', 14, 'delete_student_fund_raiser');
INSERT INTO auth_permission VALUES (46, 'Can add fund_ raiser_ profit', 15, 'add_fund_raiser_profit');
INSERT INTO auth_permission VALUES (47, 'Can change fund_ raiser_ profit', 15, 'change_fund_raiser_profit');
INSERT INTO auth_permission VALUES (48, 'Can delete fund_ raiser_ profit', 15, 'delete_fund_raiser_profit');
INSERT INTO auth_permission VALUES (49, 'Can add Trip Commitment Dashboard', 16, 'add_trip_commitment_dashboard');
INSERT INTO auth_permission VALUES (50, 'Can change Trip Commitment Dashboard', 16, 'change_trip_commitment_dashboard');
INSERT INTO auth_permission VALUES (51, 'Can delete Trip Commitment Dashboard', 16, 'delete_trip_commitment_dashboard');
INSERT INTO auth_permission VALUES (52, 'Can add Trip Current Payment Due', 17, 'add_trip_current_payment_due');
INSERT INTO auth_permission VALUES (53, 'Can change Trip Current Payment Due', 17, 'change_trip_current_payment_due');
INSERT INTO auth_permission VALUES (54, 'Can delete Trip Current Payment Due', 17, 'delete_trip_current_payment_due');
INSERT INTO auth_permission VALUES (55, 'Can add Student', 18, 'add_student');
INSERT INTO auth_permission VALUES (56, 'Can change Student', 18, 'change_student');
INSERT INTO auth_permission VALUES (57, 'Can delete Student', 18, 'delete_student');
INSERT INTO auth_permission VALUES (58, 'Can add Trip Fund Raiser Detail', 19, 'add_trip_fund_raiser_detail');
INSERT INTO auth_permission VALUES (59, 'Can change Trip Fund Raiser Detail', 19, 'change_trip_fund_raiser_detail');
INSERT INTO auth_permission VALUES (60, 'Can delete Trip Fund Raiser Detail', 19, 'delete_trip_fund_raiser_detail');
INSERT INTO auth_permission VALUES (61, 'Can add Trip Fund Raiser Profits', 20, 'add_trip_fund_raiser_profit');
INSERT INTO auth_permission VALUES (62, 'Can change Trip Fund Raiser Profits', 20, 'change_trip_fund_raiser_profit');
INSERT INTO auth_permission VALUES (63, 'Can delete Trip Fund Raiser Profits', 20, 'delete_trip_fund_raiser_profit');


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('auth_permission_id_seq', 63, true);


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO auth_user VALUES (1, 'pbkdf2_sha256$30000$kss7S4hM1Gev$zOrH4Ot7eQfQY4Kuk57RYCTWDod8VhntaJco/ce6+wk=', '2016-11-10 01:53:04.279774-05', true, 'jim', '', '', 'jim@jimbo.com', true, true, '2016-11-10 01:52:31.920545-05');


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: jim
--



--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('auth_user_id_seq', 1, true);


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: jim
--



--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('auth_user_user_permissions_id_seq', 1, false);


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO django_admin_log VALUES (1, '2016-11-10 11:14:27.322475-05', '1', 'Disney 2017', 2, '[{"changed": {"fields": ["school_year"]}}]', 9, 1);
INSERT INTO django_admin_log VALUES (2, '2016-11-10 14:24:59.178281-05', '1', 'Disney 2017', 2, '[{"changed": {"fields": ["trip_start_date", "trip_end_date"]}}]', 9, 1);
INSERT INTO django_admin_log VALUES (3, '2016-11-10 16:57:27.838886-05', '1', 'Aramark - Steeler Game', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (4, '2016-11-10 16:57:38.719771-05', '2', 'Fall Hoagies', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (5, '2016-11-10 16:57:47.75444-05', '3', 'Merchant Card', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (6, '2016-11-10 16:57:55.968906-05', '4', 'Fall Sarris', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (7, '2016-11-10 16:58:04.146794-05', '5', 'Otis Spunkmyer', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (8, '2016-11-10 16:58:11.779996-05', '6', 'Spring Sarris', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (9, '2016-11-10 16:58:19.953071-05', '7', 'Spring Hoagies', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (10, '2016-11-10 16:58:28.227186-05', '8', 'Aramark - Pitt Football Game', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (11, '2016-11-10 16:58:36.524194-05', '9', 'Aramark - Concert', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (12, '2016-11-10 16:58:43.597824-05', '10', 'Carryover', 1, '[{"added": {}}]', 8, 1);
INSERT INTO django_admin_log VALUES (13, '2016-11-10 17:04:45.505136-05', '10', 'Carryover', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (14, '2016-11-10 17:04:55.105459-05', '9', 'Aramark - Concert', 2, '[]', 8, 1);
INSERT INTO django_admin_log VALUES (15, '2016-11-10 17:05:10.179976-05', '7', 'Spring Hoagies', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (16, '2016-11-10 17:05:20.772614-05', '7', 'Spring Hoagies', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (17, '2016-11-10 17:05:30.862644-05', '6', 'Spring Sarris', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (18, '2016-11-10 17:05:44.4304-05', '5', 'Otis Spunkmyer', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (19, '2016-11-10 17:05:55.86575-05', '4', 'Fall Sarris', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (20, '2016-11-10 17:06:15.354196-05', '3', 'Merchant Card', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (21, '2016-11-10 17:06:28.052014-05', '2', 'Fall Hoagies', 2, '[{"changed": {"fields": ["super_group"]}}]', 8, 1);
INSERT INTO django_admin_log VALUES (22, '2016-11-10 22:50:24.27674-05', '1', 'Disney 2017', 2, '[{"added": {"name": "Fund Raiser", "object": "Beyonce Concert"}}, {"added": {"name": "Fund Raiser", "object": "Kenny Chesney Concert"}}, {"added": {"name": "Fund Raiser", "object": "Guns ''N Roses Concert"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}]', 9, 1);
INSERT INTO django_admin_log VALUES (23, '2016-11-10 22:59:12.323077-05', '1', 'Disney 2017', 2, '[{"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Pitt Football Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Steelers Game"}}, {"added": {"name": "Fund Raiser", "object": "Fall Hoagies"}}, {"added": {"name": "Fund Raiser", "object": "Mercant Cards"}}, {"added": {"name": "Fund Raiser", "object": "Fall Saris Candy Sale"}}, {"added": {"name": "Fund Raiser", "object": "Otis Spunkmeyer"}}, {"added": {"name": "Fund Raiser", "object": "Spring Saris Candy Sale"}}, {"added": {"name": "Fund Raiser", "object": "Spring Hoagie"}}, {"added": {"name": "Fund Raiser", "object": "2015-16 Carryover"}}]', 9, 1);
INSERT INTO django_admin_log VALUES (24, '2016-11-13 23:38:04.76088-05', '1', 'Disney 2017', 2, 'Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object". Added Trip Payment Date "Trip_Payment_Date object".', 9, 1);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('django_admin_log_id_seq', 24, true);


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO django_content_type VALUES (1, 'admin', 'logentry');
INSERT INTO django_content_type VALUES (2, 'auth', 'group');
INSERT INTO django_content_type VALUES (3, 'auth', 'user');
INSERT INTO django_content_type VALUES (4, 'auth', 'permission');
INSERT INTO django_content_type VALUES (5, 'contenttypes', 'contenttype');
INSERT INTO django_content_type VALUES (6, 'sessions', 'session');
INSERT INTO django_content_type VALUES (7, 'trip', 'fund_raiser');
INSERT INTO django_content_type VALUES (8, 'trip', 'fund_raiser_type');
INSERT INTO django_content_type VALUES (9, 'trip', 'trip');
INSERT INTO django_content_type VALUES (10, 'trip', 'trip_commitment');
INSERT INTO django_content_type VALUES (11, 'trip', 'trip_payment_date');
INSERT INTO django_content_type VALUES (12, 'trip', 'fund_raiser_item');
INSERT INTO django_content_type VALUES (13, 'trip', 'payment');
INSERT INTO django_content_type VALUES (14, 'trip', 'student_fund_raiser');
INSERT INTO django_content_type VALUES (15, 'trip', 'fund_raiser_profit');
INSERT INTO django_content_type VALUES (16, 'trip', 'trip_commitment_dashboard');
INSERT INTO django_content_type VALUES (17, 'trip', 'trip_current_payment_due');
INSERT INTO django_content_type VALUES (18, 'trip', 'student');
INSERT INTO django_content_type VALUES (19, 'trip', 'trip_fund_raiser_detail');
INSERT INTO django_content_type VALUES (20, 'trip', 'trip_fund_raiser_profit');


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('django_content_type_id_seq', 20, true);


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO django_migrations VALUES (1, 'contenttypes', '0001_initial', '2016-11-10 01:22:40.40906-05');
INSERT INTO django_migrations VALUES (2, 'auth', '0001_initial', '2016-11-10 01:22:41.507649-05');
INSERT INTO django_migrations VALUES (3, 'admin', '0001_initial', '2016-11-10 01:22:41.894533-05');
INSERT INTO django_migrations VALUES (4, 'admin', '0002_logentry_remove_auto_add', '2016-11-10 01:22:41.916465-05');
INSERT INTO django_migrations VALUES (5, 'contenttypes', '0002_remove_content_type_name', '2016-11-10 01:22:41.967619-05');
INSERT INTO django_migrations VALUES (6, 'auth', '0002_alter_permission_name_max_length', '2016-11-10 01:22:41.987624-05');
INSERT INTO django_migrations VALUES (7, 'auth', '0003_alter_user_email_max_length', '2016-11-10 01:22:42.00862-05');
INSERT INTO django_migrations VALUES (8, 'auth', '0004_alter_user_username_opts', '2016-11-10 01:22:42.031622-05');
INSERT INTO django_migrations VALUES (9, 'auth', '0005_alter_user_last_login_null', '2016-11-10 01:22:42.063426-05');
INSERT INTO django_migrations VALUES (10, 'auth', '0006_require_contenttypes_0002', '2016-11-10 01:22:42.066423-05');
INSERT INTO django_migrations VALUES (11, 'auth', '0007_alter_validators_add_error_messages', '2016-11-10 01:22:42.087493-05');
INSERT INTO django_migrations VALUES (12, 'auth', '0008_alter_user_username_max_length', '2016-11-10 01:22:42.185534-05');
INSERT INTO django_migrations VALUES (13, 'sessions', '0001_initial', '2016-11-10 01:22:42.402747-05');
INSERT INTO django_migrations VALUES (14, 'trip', '0001_initial', '2016-11-10 01:28:11.729656-05');
INSERT INTO django_migrations VALUES (15, 'trip', '0002_trip_current_trip', '2016-11-10 10:52:04.069871-05');
INSERT INTO django_migrations VALUES (16, 'trip', '0003_auto_20161110_1047', '2016-11-10 10:52:04.083787-05');
INSERT INTO django_migrations VALUES (17, 'trip', '0004_remove_trip_current_trip', '2016-11-10 10:52:04.113799-05');
INSERT INTO django_migrations VALUES (18, 'trip', '0005_trip_current_trip', '2016-11-10 10:52:48.582567-05');
INSERT INTO django_migrations VALUES (19, 'trip', '0006_trip_school_year', '2016-11-10 11:06:07.375566-05');
INSERT INTO django_migrations VALUES (20, 'trip', '0007_auto_20161110_1107', '2016-11-10 11:07:31.377358-05');
INSERT INTO django_migrations VALUES (21, 'trip', '0008_auto_20161110_1702', '2016-11-10 17:03:02.600174-05');
INSERT INTO django_migrations VALUES (22, 'trip', '0009_auto_20161110_2229', '2016-11-10 22:29:15.470862-05');
INSERT INTO django_migrations VALUES (23, 'trip', '0010_fund_raiser_fund_raiser_date', '2016-11-10 22:40:42.307223-05');
INSERT INTO django_migrations VALUES (24, 'trip', '0011_auto_20161111_0029', '2016-11-11 00:30:03.043048-05');
INSERT INTO django_migrations VALUES (25, 'trip', '0012_auto_20161111_0105', '2016-11-11 01:05:09.454478-05');
INSERT INTO django_migrations VALUES (26, 'trip', '0013_auto_20161111_0143', '2016-11-11 01:43:09.143722-05');
INSERT INTO django_migrations VALUES (27, 'trip', '0014_auto_20161113_2255', '2016-11-13 22:56:08.040167-05');
INSERT INTO django_migrations VALUES (28, 'trip', '0015_auto_20161113_2337', '2016-11-13 23:37:49.193433-05');
INSERT INTO django_migrations VALUES (29, 'trip', '0016_fund_raiser_item_payment_student_fund_rasier', '2016-11-14 00:06:56.419644-05');
INSERT INTO django_migrations VALUES (30, 'trip', '0017_auto_20161114_2318', '2016-11-14 23:18:12.571313-05');
INSERT INTO django_migrations VALUES (31, 'trip', '0018_fund_raiser_profit', '2016-11-14 23:35:19.228998-05');
INSERT INTO django_migrations VALUES (32, 'trip', '0019_auto_20161114_2351', '2016-11-14 23:51:55.444909-05');
INSERT INTO django_migrations VALUES (33, 'trip', '0020_auto_20161114_2352', '2016-11-14 23:53:03.51621-05');
INSERT INTO django_migrations VALUES (34, 'trip', '0021_auto_20161128_1214', '2016-11-28 12:14:47.1311-05');
INSERT INTO django_migrations VALUES (35, 'trip', '0022_student_svid', '2016-11-28 12:16:47.898619-05');
INSERT INTO django_migrations VALUES (36, 'trip', '0023_auto_20161128_1217', '2016-11-28 12:17:34.518815-05');
INSERT INTO django_migrations VALUES (37, 'trip', '0024_trip_commitment_student', '2016-11-28 12:45:46.28871-05');
INSERT INTO django_migrations VALUES (38, 'trip', '0025_auto_20161128_1325', '2016-11-28 13:25:53.266076-05');
INSERT INTO django_migrations VALUES (39, 'trip', '0026_auto_20161211_0018', '2016-12-11 00:19:37.81015-05');
INSERT INTO django_migrations VALUES (40, 'trip', '0027_auto_20161211_0020', '2016-12-11 00:20:23.313485-05');


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('django_migrations_id_seq', 40, true);


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO django_session VALUES ('r8rnucmbpv3htpp4gxj22j5o052z0ety', 'MGM1ZmQwY2Y1YWZhNDYxYTRiZGQ3ODg2M2QzY2E1YjYxNTI2YTA5MTp7Il9hdXRoX3VzZXJfYmFja2VuZCI6ImRqYW5nby5jb250cmliLmF1dGguYmFja2VuZHMuTW9kZWxCYWNrZW5kIiwiX2F1dGhfdXNlcl9pZCI6IjEiLCJfYXV0aF91c2VyX2hhc2giOiI3ZjM1MzVhOTU2YmQ2NzY1ZmU4ZDQ5M2YwZmM2MDgzYTM4YjcyNDNjIn0=', '2016-11-24 01:53:04.282958-05');


--
-- Data for Name: trip_fund_raiser; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_fund_raiser VALUES (1, 'Beyonce Concert', 95.00, NULL, 9, 1, '2016-05-31');
INSERT INTO trip_fund_raiser VALUES (2, 'Kenny Chesney Concert', 120.00, NULL, 9, 1, '2016-07-02');
INSERT INTO trip_fund_raiser VALUES (3, 'Guns ''N Roses Concert', 95.00, NULL, 9, 1, '2016-07-12');
INSERT INTO trip_fund_raiser VALUES (4, 'Steelers Game', 125.00, NULL, 1, 1, '2016-08-12');
INSERT INTO trip_fund_raiser VALUES (5, 'Steelers Game', 125.00, NULL, 1, 1, '2016-08-18');
INSERT INTO trip_fund_raiser VALUES (6, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-09-03');
INSERT INTO trip_fund_raiser VALUES (7, 'Pitt Football Game', 125.00, NULL, 8, 1, '2016-09-10');
INSERT INTO trip_fund_raiser VALUES (8, 'Steelers Game', 125.00, NULL, 1, 1, '2016-09-18');
INSERT INTO trip_fund_raiser VALUES (9, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-10-01');
INSERT INTO trip_fund_raiser VALUES (10, 'Steelers Game', 125.00, NULL, 1, 1, '2016-10-02');
INSERT INTO trip_fund_raiser VALUES (11, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-10-08');
INSERT INTO trip_fund_raiser VALUES (12, 'Steelers Game', 125.00, NULL, 1, 1, '2016-10-09');
INSERT INTO trip_fund_raiser VALUES (13, 'Steelers Game', 125.00, NULL, 1, 1, '2016-10-23');
INSERT INTO trip_fund_raiser VALUES (14, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-10-27');
INSERT INTO trip_fund_raiser VALUES (15, 'Steelers Game', 125.00, NULL, 1, 1, '2016-11-13');
INSERT INTO trip_fund_raiser VALUES (16, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-11-19');
INSERT INTO trip_fund_raiser VALUES (17, 'Pitt Football Game', 100.00, NULL, 8, 1, '2016-11-26');
INSERT INTO trip_fund_raiser VALUES (18, 'Steelers Game', 125.00, NULL, 1, 1, '2016-12-04');
INSERT INTO trip_fund_raiser VALUES (19, 'Steelers Game', 185.00, NULL, 1, 1, '2016-12-25');
INSERT INTO trip_fund_raiser VALUES (20, 'Steelers Game', 145.00, NULL, 1, 1, '2017-01-01');
INSERT INTO trip_fund_raiser VALUES (21, 'Fall Hoagies', NULL, NULL, 2, 1, '2016-10-28');
INSERT INTO trip_fund_raiser VALUES (22, 'Mercant Cards', 6.00, NULL, 3, 1, '2016-10-28');
INSERT INTO trip_fund_raiser VALUES (23, 'Fall Saris Candy Sale', NULL, NULL, 4, 1, '2016-11-30');
INSERT INTO trip_fund_raiser VALUES (24, 'Otis Spunkmeyer', NULL, NULL, 5, 1, '2016-12-15');
INSERT INTO trip_fund_raiser VALUES (25, 'Spring Saris Candy Sale', NULL, NULL, 6, 1, '2017-02-28');
INSERT INTO trip_fund_raiser VALUES (26, 'Spring Hoagie', NULL, NULL, 7, 1, '2017-02-28');
INSERT INTO trip_fund_raiser VALUES (27, '2015-16 Carryover', NULL, NULL, 10, 1, '2016-05-30');


--
-- Name: trip_fund_raiser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_fund_raiser_id_seq', 27, true);


--
-- Data for Name: trip_fund_raiser_item; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_fund_raiser_item VALUES (2, 'Italian Deluxe', 1, 8.75, 2.25, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (3, 'Turkey \& Cheese', 2, 7.75, 2.35, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (4, 'Italian Pizza', 3, 7.75, 2.35, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (5, 'Va Ham \& Cheese', 4, 7.75, 2.35, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (6, 'Meatball', 5, 5.75, 2.25, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (7, 'Pepperoni Rolls', 6, 7.25, 3.00, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (8, 'Apple Dumplings', 7, 10.50, 3.50, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (9, 'Apple Pie', 8, 12.00, 3.25, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (10, 'Cherry Pie', 9, 12.00, 3.00, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (11, 'Apple Walnut', 10, 12.00, 3.25, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (12, 'Pumpkin Pie', 11, 12.00, 3.00, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (13, 'Peach Pie', 12, 12.00, 3.25, NULL, 21);
INSERT INTO trip_fund_raiser_item VALUES (14, 'Pumpkin Roll', 13, 11.50, 4.25, NULL, 21);


--
-- Name: trip_fund_raiser_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_fund_raiser_item_id_seq', 14, true);


--
-- Data for Name: trip_fund_raiser_profit; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_fund_raiser_profit VALUES (1, 95.00, '2016-05-31 00:00:00-04', 262, 1);
INSERT INTO trip_fund_raiser_profit VALUES (2, 120.00, '2016-07-02 00:00:00-04', 262, 2);
INSERT INTO trip_fund_raiser_profit VALUES (3, 95.00, '2016-05-31 00:00:00-04', 265, 1);
INSERT INTO trip_fund_raiser_profit VALUES (4, 120.00, '2016-07-02 00:00:00-04', 265, 2);


--
-- Name: trip_fund_raiser_profit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_fund_raiser_profit_id_seq', 4, true);


--
-- Data for Name: trip_fund_raiser_type; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_fund_raiser_type VALUES (1, 'Aramark - Steeler Game', 'Aramark');
INSERT INTO trip_fund_raiser_type VALUES (8, 'Aramark - Pitt Football Game', 'Aramark');
INSERT INTO trip_fund_raiser_type VALUES (10, 'Carryover', 'Carryover');
INSERT INTO trip_fund_raiser_type VALUES (9, 'Aramark - Concert', 'Aramark');
INSERT INTO trip_fund_raiser_type VALUES (7, 'Spring Hoagies', 'Hoagie Sale');
INSERT INTO trip_fund_raiser_type VALUES (6, 'Spring Sarris', 'Sarris Candy');
INSERT INTO trip_fund_raiser_type VALUES (5, 'Otis Spunkmyer', 'Otis Spunkmyer');
INSERT INTO trip_fund_raiser_type VALUES (4, 'Fall Sarris', 'Sarris Candy');
INSERT INTO trip_fund_raiser_type VALUES (3, 'Merchant Card', 'Merchant Card');
INSERT INTO trip_fund_raiser_type VALUES (2, 'Fall Hoagies', 'Hoagie Sale');


--
-- Name: trip_fund_raiser_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_fund_raiser_type_id_seq', 10, true);


--
-- Data for Name: trip_payment; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_payment VALUES (1, '2016-11-21', 250.00, '4587', NULL, 6);
INSERT INTO trip_payment VALUES (2, '2016-11-21', 250.00, '4587', NULL, 6);
INSERT INTO trip_payment VALUES (3, '2016-11-21', 250.00, '4578', NULL, 4);
INSERT INTO trip_payment VALUES (12, '2016-11-22', 250.00, '7894', NULL, 235);
INSERT INTO trip_payment VALUES (13, '2016-11-22', 0.00, ' ', NULL, 12);
INSERT INTO trip_payment VALUES (14, '2016-11-22', 300.00, '456789', NULL, 235);
INSERT INTO trip_payment VALUES (15, '2016-11-22', 0.00, ' ', NULL, 14);
INSERT INTO trip_payment VALUES (16, '2016-11-22', 0.00, ' ', NULL, 235);
INSERT INTO trip_payment VALUES (17, '2016-11-22', 200.00, '7896', NULL, 236);
INSERT INTO trip_payment VALUES (18, '2016-11-22', 200.00, '7896', NULL, 236);
INSERT INTO trip_payment VALUES (19, '2016-11-22', 0.00, ' ', NULL, 236);
INSERT INTO trip_payment VALUES (20, '2016-11-22', 313.00, '7894', NULL, 238);
INSERT INTO trip_payment VALUES (22, '2016-11-22', 125.00, '112233', NULL, 234);
INSERT INTO trip_payment VALUES (23, '2016-11-22', 0.00, ' ', NULL, 4);
INSERT INTO trip_payment VALUES (4, '2016-11-22', 125.00, '9630', '2016-11-24', 4);
INSERT INTO trip_payment VALUES (21, '2016-11-22', 256.00, '8520147', '2016-11-23', 238);
INSERT INTO trip_payment VALUES (26, '2016-11-14', 560.00, '9999', NULL, 9);
INSERT INTO trip_payment VALUES (27, '2016-11-14', 560.00, '9999', NULL, 9);
INSERT INTO trip_payment VALUES (28, '2016-11-04', 410.00, '7777', '2016-11-10', 9);
INSERT INTO trip_payment VALUES (29, '2016-11-04', 111.11, '3333', '2016-11-12', 9);
INSERT INTO trip_payment VALUES (30, '2016-11-01', 2.25, '8888', NULL, 9);
INSERT INTO trip_payment VALUES (31, '2016-10-15', 16.25, '7894', '2016-10-22', 9);
INSERT INTO trip_payment VALUES (32, '2016-10-01', 19.95, '987', NULL, 9);
INSERT INTO trip_payment VALUES (33, '2016-10-05', 100.00, '96369', NULL, 9);
INSERT INTO trip_payment VALUES (34, '2016-10-15', 100.00, '98789', NULL, 9);
INSERT INTO trip_payment VALUES (35, '2016-10-25', 145.00, '1', NULL, 9);
INSERT INTO trip_payment VALUES (36, '2016-10-18', 10.00, '1', NULL, 9);
INSERT INTO trip_payment VALUES (37, '2016-11-04', 20.00, '55', NULL, 9);
INSERT INTO trip_payment VALUES (38, '2016-11-14', 11.00, '66', NULL, 9);
INSERT INTO trip_payment VALUES (39, '2016-10-25', 10.00, '54', NULL, 9);
INSERT INTO trip_payment VALUES (40, '2016-11-01', 5.00, '45', NULL, 9);
INSERT INTO trip_payment VALUES (41, '2016-11-02', 10.00, '6', NULL, 9);
INSERT INTO trip_payment VALUES (42, '2016-11-03', 10.00, '77', NULL, 9);
INSERT INTO trip_payment VALUES (43, '2016-10-31', 10.00, '12', NULL, 9);
INSERT INTO trip_payment VALUES (44, '2016-10-31', 10.00, '74', NULL, 9);
INSERT INTO trip_payment VALUES (45, '2016-10-31', 10.00, '74', NULL, 9);
INSERT INTO trip_payment VALUES (46, '2016-10-02', 15.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (47, '2016-10-03', 24.00, '12', NULL, 9);
INSERT INTO trip_payment VALUES (48, '2016-10-04', 25.00, '34', NULL, 9);
INSERT INTO trip_payment VALUES (49, '2016-10-06', 74.00, '45', NULL, 9);
INSERT INTO trip_payment VALUES (50, '2016-10-07', 4.00, '456', NULL, 9);
INSERT INTO trip_payment VALUES (51, '2016-10-08', 1.00, '4', NULL, 9);
INSERT INTO trip_payment VALUES (52, '2016-10-08', 1.00, '4', NULL, 9);
INSERT INTO trip_payment VALUES (53, '2016-10-08', 1.00, '4', NULL, 9);
INSERT INTO trip_payment VALUES (54, '2016-10-09', 2.00, '2', NULL, 9);
INSERT INTO trip_payment VALUES (55, '2016-10-10', 1.00, '4', NULL, 9);
INSERT INTO trip_payment VALUES (56, '2016-10-10', 1.00, '4', NULL, 9);
INSERT INTO trip_payment VALUES (57, '2016-10-11', 2.00, '234', NULL, 9);
INSERT INTO trip_payment VALUES (58, '2016-10-11', 2.00, '234', NULL, 9);
INSERT INTO trip_payment VALUES (59, '2016-10-11', 2.00, '234', NULL, 9);
INSERT INTO trip_payment VALUES (60, '2016-10-11', 2.00, '234', NULL, 9);
INSERT INTO trip_payment VALUES (61, '2016-10-11', 2.00, '234', NULL, 9);
INSERT INTO trip_payment VALUES (62, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (63, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (64, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (65, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (66, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (67, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (68, '2016-10-12', 1.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (25, '2016-11-16', 214.00, '789654', '2016-11-18', 9);
INSERT INTO trip_payment VALUES (69, '2016-10-17', 2.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (70, '2016-10-17', 2.00, '23', NULL, 9);
INSERT INTO trip_payment VALUES (71, '2016-10-18', 12.00, '12', NULL, 9);
INSERT INTO trip_payment VALUES (72, '2016-10-18', 12.00, '12', NULL, 9);
INSERT INTO trip_payment VALUES (73, '2016-10-19', 12.00, '123', NULL, 9);
INSERT INTO trip_payment VALUES (24, '2016-11-22', 10.00, '123', '2016-12-02', 17);
INSERT INTO trip_payment VALUES (74, '2016-12-02', 25.00, '115599', NULL, 17);
INSERT INTO trip_payment VALUES (75, '2016-12-02', 25.00, '115599', NULL, 17);
INSERT INTO trip_payment VALUES (76, '2016-12-02', 25.00, '115599', NULL, 17);
INSERT INTO trip_payment VALUES (77, '2016-12-02', 25.00, '115599', NULL, 17);
INSERT INTO trip_payment VALUES (78, '2016-12-04', 15.00, '789', NULL, 17);
INSERT INTO trip_payment VALUES (79, '2016-11-15', 5.00, '123', NULL, 17);
INSERT INTO trip_payment VALUES (80, '2016-12-10', 12.00, '123', NULL, 9);


--
-- Name: trip_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_payment_id_seq', 80, true);


--
-- Data for Name: trip_student; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_student VALUES (1, 'Donald', 'Trump', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (2, 'Hillary', 'Clinton', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (3, 'Bill', 'Gates', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (4, 'George', 'Bush', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (5, 'KATHERINE', 'BABLAK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (6, 'GRACE', 'BARNES', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (7, 'JORDAN', 'BATHER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (8, 'ANTHONY', 'BAYLE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (10, 'ALLISON', 'BEITER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (11, 'MICHAEL', 'BENESKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (12, 'KATHRYN', 'BERKLEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (13, 'GINA', 'BIASE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (14, 'ELIZABETH', 'BITTNER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (15, 'OWEN', 'BLAZER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (16, 'GIANNA', 'BOCCIERI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (17, 'PHOEBE', 'BOWERS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (19, 'MAUREEN', 'BRICKER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (20, 'BRITTANY', 'BROCK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (21, 'BREANNA', 'BRUNI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (22, 'SYDNEY', 'BRUNS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (23, 'GABRIELLE', 'BRYSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (24, 'MASON', 'BUSH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (25, 'KIRSTEN', 'BUSSARD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (26, 'LYNDSEY', 'BUTLER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (27, 'RAVEN', 'CAMPBELL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (28, 'MADELYN', 'CARPENTER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (29, 'ELLEN', 'CASEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (30, 'BRIANNA', 'CASKEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (31, 'ALEXANDER', 'CASSESE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (32, 'CAILEE', 'CHESKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (33, 'KATE', 'CHIEPPOR', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (34, 'STEFAN', 'CHITU', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (35, 'HALEY', 'CLANCY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (36, 'CARLY', 'CLARKE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (37, 'SAMANTHA', 'CONDRICK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (38, 'ASHLEY', 'CONROY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (39, 'LAKEN', 'COOPER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (40, 'MATTHEW', 'COSCO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (41, 'ALEXANDRA', 'COWELL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (42, 'SETH', 'COWELL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (43, 'ALLISON', 'COX', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (44, 'HALEY', 'CRAMER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (45, 'TARA', 'CREADY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (46, 'BRAYANN', 'CRISS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (47, 'MIA', 'CUCCARO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (48, 'REAGAN', 'CURRY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (49, 'KATHRYN', 'CURTIS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (50, 'HALEY', 'DAVINSIZER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (51, 'MIKAYLA', 'DAVIS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (52, 'MEGAN', 'DAVIS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (53, 'CALEB', 'DAWSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (54, 'CHARLEE', 'DAWSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (55, 'ELAINA', 'DEWITT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (56, 'NINA', 'DILLON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (57, 'KENNA', 'DONALDSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (58, 'LAUREN', 'DONNELLY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (59, 'ASHLEY', 'DOURLAIN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (60, 'ANGELINA', 'DRAGOVITS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (61, 'NAZLI', 'DUM', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (62, 'SABRINA', 'DUNLAP', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (63, 'MARANDA', 'DUNN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (64, 'NATALIE', 'DWOREK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (65, 'COLE', 'ECKENRODE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (66, 'AMANDA', 'EDWARDS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (67, 'LINDSEY', 'EDWARDS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (68, 'GAVIN', 'FAGAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (69, 'CORYN', 'FERGUSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (70, 'MADISON', 'FERRINGER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (71, 'TYLER', 'FLOOD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (72, 'OLIVIA', 'FORTE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (73, 'OKON', 'FRANCIS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (74, 'CHRISTY', 'FRANK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (75, 'KAYLA', 'FREDERICK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (76, 'JOSEPH', 'FRESHLY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (77, 'MORGAN', 'FUCHS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (78, 'ARLET', 'FUNES-COBAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (79, 'ZACHARY', 'GANDEE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (80, 'KYLEA', 'GARCIA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (81, 'BELLA', 'GARDNER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (82, 'JOHN', 'GARGASZ', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (83, 'HOLLY', 'GARRETT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (84, 'AXTON', 'GARRETT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (85, 'ELLI', 'GIANAKAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (86, 'MARISLEYSIS', 'GONZALEZ', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (87, 'MEGHAN', 'GORMLY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (88, 'PRESTON', 'GRAVLEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (89, 'CLAYTON', 'GROSS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (90, 'SAMUEL', 'GUERRINI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (91, 'LYNSEY', 'HABIG', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (92, 'BRADLEY', 'HAHN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (93, 'EMILY', 'HALUCK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (94, 'LINDSAY', 'HANS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (95, 'CAMERON', 'HANSEN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (96, 'KILEY', 'HAYES', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (97, 'NICOLE', 'HEALY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (98, 'EMILY', 'HENRIE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (99, 'EMMA', 'HOUSEHOLDER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (100, 'TANNER', 'HOWARD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (101, 'THANH', 'HUYNH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (102, 'GAVIN', 'JACKMAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (103, 'LINDSEY', 'JOHNS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (104, 'DAKOTA', 'JONES', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (105, 'PAMELA', 'JUNQUEIRA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (106, 'BETHANY', 'KAVANAGH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (107, 'CLAIRE', 'KESSEL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (108, 'TETYANA', 'KHORLANOVA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (109, 'JACOB', 'KIO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (110, 'OLIVIA', 'KISIDAY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (111, 'LILY', 'KNOCHEL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (112, 'KYLE', 'KOLARICH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (113, 'SAMANTHA', 'KOLLEK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (114, 'TAYLOR', 'KOPP', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (115, 'MYA', 'KOWALSKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (116, 'KAMDEN', 'KOZIAK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (117, 'AMANDA Q', 'ALTIMUS', '', '', '', NULL, NULL);
INSERT INTO trip_student VALUES (118, 'KATHERINE', 'KRIZNIK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (119, 'LANE', 'KUMMER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (120, 'ARIZONA', 'KUNSELMAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (121, 'NATALI', 'LACHOWSKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (122, 'JAYNA', 'LEBER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (123, 'CADEN', 'LEIGHTY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (124, 'NICHOLAS', 'LESSER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (125, 'STONE', 'LEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (126, 'MATTHEW', 'LINK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (127, 'MICAH', 'LINK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (128, 'RYAN', 'LIPSCOMB', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (129, 'FAITH', 'LISTON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (130, 'EMILY', 'LOCKHART', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (131, 'ODALYS', 'LOPEZ', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (132, 'GRACE', 'LOPICCOLO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (133, 'KATHERYN', 'LOSEE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (134, 'RACHEL', 'LOWERY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (135, 'TRESSA', 'MACPHERSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (136, 'ANNA', 'MADDEN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (137, 'OLIVIA', 'MADEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (138, 'ADELINE', 'MALAK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (139, 'JUSTIN', 'MALEZI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (140, 'ROBERT', 'MALONE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (141, 'CHEYENNE', 'MANNAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (142, 'LAUREN', 'MARTIN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (143, 'ELAINA', 'MASTROIANNI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (144, 'CLAIRA', 'MATTHEWS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (145, 'BRIA', 'MCAFEE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (146, 'BRIANNA', 'MCCLOSKEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (147, 'MCKENNA', 'MCCRIGHT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (148, 'CONNOR', 'MCDONALD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (149, 'MEGHAN', 'MCGINNIS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (150, 'DACE', 'MCGONIGAL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (151, 'LAUREN', 'MCKINLEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (152, 'EVELYN', 'MCLAUGHLIN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (153, 'GRACE', 'MCSWANEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (154, 'CHRISTIAN', 'MEEDER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (155, 'BRYCE', 'MEEK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (156, 'LAUREN', 'MERTEN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (157, 'KATHRYN', 'MESSER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (158, 'PARKER', 'MICHAELS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (159, 'ANTHONY', 'MILLS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (160, 'JACOB', 'MINEWEASER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (161, 'MEGAN', 'MITCHELL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (162, 'ALYSSA', 'MITCHELL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (163, 'LAUREN', 'MOORE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (164, 'LAUREN', 'MUDRANY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (165, 'MATTHEW', 'MULARSKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (166, 'AUSTIN', 'MYERS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (167, 'REAGAN', 'NEFF', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (168, 'ABIGALE', 'NEWMAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (169, 'ANGELA', 'NEWMAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (170, 'LAUREN', 'NIEMCZYK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (171, 'CHRISTOPHER', 'NOAH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (172, 'COLTON', 'NOBLE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (173, 'JACLYN', 'NOONAN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (174, 'SHANNON', 'OSHEA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (175, 'RACHEL', 'PALASKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (176, 'CHARLOTTE', 'PANZERI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (177, 'ALEXANDRA', 'PARISE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (178, 'AVALON', 'PARSONS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (179, 'NATALIE', 'PAULOVICH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (180, 'VANESSA', 'PEFFER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (181, 'JOSHUA', 'PERRY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (182, 'JUSTIN', 'PITYK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (183, 'AMANDA', 'PRISTAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (184, 'BRIANNA', 'PROVENZANO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (185, 'HANNAH', 'PRY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (186, 'ALLISON', 'PTAK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (187, 'ASHLEY', 'RAMFOS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (188, 'AMELIA', 'REESE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (189, 'MASON', 'RICHARDS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (190, 'HANNAH', 'RICHTER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (191, 'GRIFFIN', 'RING', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (192, 'KARA', 'RISTEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (193, 'JORDAN', 'RITCHEY', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (194, 'AMBER', 'ROCHFORD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (195, 'OLIVIA', 'RUPERT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (196, 'ANDREW', 'RUPIK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (197, 'JENA', 'SABOL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (198, 'HALEY', 'SALVA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (199, 'FRANCESCA', 'SALVATORE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (200, 'MICHAEL', 'SANTAVICCA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (201, 'DIANA', 'SCHULTIES', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (202, 'KATIE', 'SCHWERIN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (203, 'MADISON', 'SEGAR', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (204, 'LAILA', 'SENFF', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (205, 'PORTIA', 'SHONDELMEYER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (206, 'JORDAN', 'SHOWERS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (207, 'MAX', 'SKEEN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (208, 'MADELINE', 'SLOAF', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (209, 'GRACE', 'SLOAT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (210, 'JACOB', 'SMELTZER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (211, 'KENDALL', 'SMITH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (212, 'PARKER', 'SMITH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (213, 'ALYSSA', 'SMITH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (214, 'ZOE', 'SOVEK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (215, 'MEGAN', 'SPARK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (216, 'CASSIDY', 'SPENCER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (217, 'KATHERINE', 'SPINELLI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (218, 'KRYSTEN', 'STANFORD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (219, 'ZOE', 'STEBBINS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (220, 'CASSANDRA', 'STEIGHNER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (221, 'ALEXA', 'STENGEL', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (222, 'HAILEY', 'STEVENSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (223, 'JORDAN', 'STIPETICH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (224, 'JACOB', 'STRATTON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (225, 'ABIGAIL', 'SUMMERS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (226, 'RILEY', 'SURRATT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (227, 'BRYNNE', 'SWANN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (228, 'EMILY', 'TEKELENBURG', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (229, 'TAYLOR', 'THOMPSON', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (230, 'SOMMER', 'TOMINELLO', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (231, 'LYDIA', 'TROUT', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (232, 'VIVIAN', 'TRUONG', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (233, 'JACLYN', 'VALENTAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (234, 'STEPHEN', 'VANDRAK', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (235, 'SARAH', 'VEVERKA', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (236, 'RACHEL', 'VILLEGAS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (237, 'ALYSSA', 'WAGNER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (238, 'ASHLEY', 'WALKER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (239, 'ALAYNA', 'WALKER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (240, 'SPENCER', 'WALSH', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (241, 'ALEXA', 'WARREN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (242, 'ISABEL', 'WARREN', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (243, 'MACKINLEY', 'WEAVER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (244, 'MORGAN', 'WEHR', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (245, 'ELEXA', 'WHITE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (246, 'KERRY', 'WHITTLE', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (247, 'CLAIRE', 'WILLIAMS', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (248, 'KRISTA', 'WINNER', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (249, 'EMMA', 'WOODARD', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (250, 'CAITLIN', 'WROBLEWSKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (251, 'KATHERINE', 'YANEZ', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (252, 'JACK', 'YOUNG', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (253, 'PACE', 'ZEC', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (254, 'MIA', 'ZEC', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (255, 'ALEXANDER', 'ZOWACKI', NULL, NULL, NULL, NULL, NULL);
INSERT INTO trip_student VALUES (256, 'Newest', 'Entry', 'new@email.com', '412-555-1212', '', NULL, NULL);
INSERT INTO trip_student VALUES (257, 'Mary', 'Lamb', 'MarysLamb@baah.com', '', '', NULL, NULL);
INSERT INTO trip_student VALUES (259, 'George', 'Washington', '', '', '', NULL, NULL);
INSERT INTO trip_student VALUES (260, 'Nancy Marie', 'Drew', '', '', '', NULL, NULL);
INSERT INTO trip_student VALUES (18, 'CARSON', 'BRETHAUER', '', '', '', '1234', '');
INSERT INTO trip_student VALUES (9, 'MIRANDA', 'BEACHEM', 'email@email.com', '', '', '1234', '');
INSERT INTO trip_student VALUES (262, 'Atest', 'Aa Test', '', '', '', '1234', '');
INSERT INTO trip_student VALUES (261, 'ABBY', 'ANDREWS', '', '', '', '', '');


--
-- Data for Name: trip_student_fund_raiser; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_student_fund_raiser VALUES (1, 16, 2, 265);
INSERT INTO trip_student_fund_raiser VALUES (2, 8, 3, 265);
INSERT INTO trip_student_fund_raiser VALUES (3, 3, 4, 265);
INSERT INTO trip_student_fund_raiser VALUES (4, 12, 5, 265);
INSERT INTO trip_student_fund_raiser VALUES (5, 20, 6, 265);
INSERT INTO trip_student_fund_raiser VALUES (6, 7, 7, 265);
INSERT INTO trip_student_fund_raiser VALUES (7, 100, 8, 265);
INSERT INTO trip_student_fund_raiser VALUES (8, 1, 9, 265);
INSERT INTO trip_student_fund_raiser VALUES (9, 2, 10, 265);
INSERT INTO trip_student_fund_raiser VALUES (10, 3, 11, 265);
INSERT INTO trip_student_fund_raiser VALUES (11, 4, 12, 265);
INSERT INTO trip_student_fund_raiser VALUES (12, 5, 13, 265);
INSERT INTO trip_student_fund_raiser VALUES (13, 6, 14, 265);


--
-- Name: trip_student_fund_rasier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_student_fund_rasier_id_seq', 13, true);


--
-- Name: trip_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_student_id_seq', 280, true);


--
-- Data for Name: trip_trip; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_trip VALUES (1, 'Disney 2017', 1298.00, 48.00, 'This is the trip company', 'Trip company contact name', '(412) 555-1515', 'Trip.Company@email.com', 'Diana Colbert', 'Diana.Colbert@email.com', true, 2017, '2017-04-11', '2017-04-07');


--
-- Data for Name: trip_trip_commitment; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_trip_commitment VALUES (14, 10, '3', 'Y', false, 1, 9);
INSERT INTO trip_trip_commitment VALUES (4, 10, NULL, 'Y', true, 1, 1);
INSERT INTO trip_trip_commitment VALUES (5, 9, NULL, 'Y', true, 1, 2);
INSERT INTO trip_trip_commitment VALUES (6, 11, NULL, 'Y', true, 1, 3);
INSERT INTO trip_trip_commitment VALUES (7, 11, NULL, 'Y', false, 1, 4);
INSERT INTO trip_trip_commitment VALUES (10, 10, NULL, 'Y', true, 1, 5);
INSERT INTO trip_trip_commitment VALUES (11, 10, NULL, 'Y', false, 1, 6);
INSERT INTO trip_trip_commitment VALUES (12, 9, NULL, 'U', false, 1, 7);
INSERT INTO trip_trip_commitment VALUES (13, 10, NULL, 'Y', true, 1, 8);
INSERT INTO trip_trip_commitment VALUES (15, 10, NULL, 'Y', true, 1, 10);
INSERT INTO trip_trip_commitment VALUES (16, 9, NULL, 'Y', false, 1, 11);
INSERT INTO trip_trip_commitment VALUES (17, 9, NULL, 'U', false, 1, 12);
INSERT INTO trip_trip_commitment VALUES (18, 10, NULL, 'Y', false, 1, 13);
INSERT INTO trip_trip_commitment VALUES (19, 9, NULL, 'Y', true, 1, 14);
INSERT INTO trip_trip_commitment VALUES (20, 9, NULL, 'N', false, 1, 15);
INSERT INTO trip_trip_commitment VALUES (21, 10, NULL, 'Y', true, 1, 16);
INSERT INTO trip_trip_commitment VALUES (22, 10, NULL, 'N', false, 1, 17);
INSERT INTO trip_trip_commitment VALUES (23, 9, NULL, 'N', false, 1, 18);
INSERT INTO trip_trip_commitment VALUES (24, 10, NULL, 'Y', true, 1, 19);
INSERT INTO trip_trip_commitment VALUES (25, 10, NULL, 'N', false, 1, 20);
INSERT INTO trip_trip_commitment VALUES (26, 10, NULL, 'N', false, 1, 21);
INSERT INTO trip_trip_commitment VALUES (27, 9, NULL, 'U', false, 1, 22);
INSERT INTO trip_trip_commitment VALUES (28, 9, NULL, 'U', false, 1, 23);
INSERT INTO trip_trip_commitment VALUES (29, 9, NULL, 'N', false, 1, 24);
INSERT INTO trip_trip_commitment VALUES (30, 10, NULL, 'Y', false, 1, 25);
INSERT INTO trip_trip_commitment VALUES (31, 10, NULL, 'Y', false, 1, 26);
INSERT INTO trip_trip_commitment VALUES (32, 10, NULL, 'Y', true, 1, 27);
INSERT INTO trip_trip_commitment VALUES (33, 9, NULL, 'Y', false, 1, 28);
INSERT INTO trip_trip_commitment VALUES (34, 9, NULL, 'Y', true, 1, 29);
INSERT INTO trip_trip_commitment VALUES (35, 10, NULL, 'N', false, 1, 30);
INSERT INTO trip_trip_commitment VALUES (36, 10, NULL, 'Y', true, 1, 31);
INSERT INTO trip_trip_commitment VALUES (37, 9, NULL, 'Y', false, 1, 32);
INSERT INTO trip_trip_commitment VALUES (38, 9, NULL, 'U', false, 1, 33);
INSERT INTO trip_trip_commitment VALUES (39, 10, NULL, 'Y', false, 1, 34);
INSERT INTO trip_trip_commitment VALUES (40, 10, NULL, 'U', false, 1, 35);
INSERT INTO trip_trip_commitment VALUES (41, 9, NULL, 'Y', false, 1, 36);
INSERT INTO trip_trip_commitment VALUES (42, 10, NULL, 'U', false, 1, 37);
INSERT INTO trip_trip_commitment VALUES (43, 10, NULL, 'Y', false, 1, 38);
INSERT INTO trip_trip_commitment VALUES (44, 10, NULL, 'N', false, 1, 39);
INSERT INTO trip_trip_commitment VALUES (45, 10, NULL, 'Y', false, 1, 40);
INSERT INTO trip_trip_commitment VALUES (46, 10, NULL, 'Y', false, 1, 41);
INSERT INTO trip_trip_commitment VALUES (47, 9, NULL, 'Y', false, 1, 42);
INSERT INTO trip_trip_commitment VALUES (48, 9, NULL, 'Y', false, 1, 43);
INSERT INTO trip_trip_commitment VALUES (49, 9, NULL, 'U', false, 1, 44);
INSERT INTO trip_trip_commitment VALUES (50, 10, NULL, 'Y', true, 1, 45);
INSERT INTO trip_trip_commitment VALUES (51, 9, NULL, 'Y', false, 1, 46);
INSERT INTO trip_trip_commitment VALUES (52, 10, NULL, 'U', false, 1, 47);
INSERT INTO trip_trip_commitment VALUES (53, 10, NULL, 'Y', true, 1, 48);
INSERT INTO trip_trip_commitment VALUES (54, 9, NULL, 'Y', false, 1, 49);
INSERT INTO trip_trip_commitment VALUES (55, 10, NULL, 'Y', true, 1, 50);
INSERT INTO trip_trip_commitment VALUES (56, 10, NULL, 'Y', false, 1, 51);
INSERT INTO trip_trip_commitment VALUES (57, 10, NULL, 'Y', true, 1, 52);
INSERT INTO trip_trip_commitment VALUES (58, 9, NULL, 'N', false, 1, 53);
INSERT INTO trip_trip_commitment VALUES (59, 9, NULL, 'U', false, 1, 54);
INSERT INTO trip_trip_commitment VALUES (60, 10, NULL, 'Y', true, 1, 55);
INSERT INTO trip_trip_commitment VALUES (61, 9, NULL, 'Y', true, 1, 56);
INSERT INTO trip_trip_commitment VALUES (62, 10, NULL, 'U', false, 1, 57);
INSERT INTO trip_trip_commitment VALUES (63, 10, NULL, 'Y', false, 1, 58);
INSERT INTO trip_trip_commitment VALUES (64, 10, NULL, 'Y', true, 1, 59);
INSERT INTO trip_trip_commitment VALUES (65, 9, NULL, 'Y', true, 1, 60);
INSERT INTO trip_trip_commitment VALUES (66, 10, NULL, 'Y', false, 1, 61);
INSERT INTO trip_trip_commitment VALUES (67, 10, NULL, 'Y', false, 1, 62);
INSERT INTO trip_trip_commitment VALUES (68, 9, NULL, 'N', false, 1, 63);
INSERT INTO trip_trip_commitment VALUES (69, 10, NULL, 'Y', true, 1, 64);
INSERT INTO trip_trip_commitment VALUES (70, 9, NULL, 'N', false, 1, 65);
INSERT INTO trip_trip_commitment VALUES (71, 9, NULL, 'Y', true, 1, 66);
INSERT INTO trip_trip_commitment VALUES (72, 9, NULL, 'N', false, 1, 67);
INSERT INTO trip_trip_commitment VALUES (73, 10, NULL, 'N', false, 1, 68);
INSERT INTO trip_trip_commitment VALUES (74, 9, NULL, 'N', false, 1, 69);
INSERT INTO trip_trip_commitment VALUES (75, 10, NULL, 'Y', true, 1, 70);
INSERT INTO trip_trip_commitment VALUES (76, 9, NULL, 'Y', true, 1, 71);
INSERT INTO trip_trip_commitment VALUES (227, 9, NULL, 'N', false, 1, 223);
INSERT INTO trip_trip_commitment VALUES (77, 10, NULL, 'Y', true, 1, 72);
INSERT INTO trip_trip_commitment VALUES (78, 9, NULL, 'U', false, 1, 73);
INSERT INTO trip_trip_commitment VALUES (79, 9, NULL, 'N', false, 1, 74);
INSERT INTO trip_trip_commitment VALUES (80, 9, NULL, 'U', false, 1, 75);
INSERT INTO trip_trip_commitment VALUES (81, 9, NULL, 'Y', true, 1, 76);
INSERT INTO trip_trip_commitment VALUES (82, 9, NULL, 'Y', true, 1, 77);
INSERT INTO trip_trip_commitment VALUES (83, 9, NULL, 'N', false, 1, 78);
INSERT INTO trip_trip_commitment VALUES (84, 10, NULL, 'Y', true, 1, 79);
INSERT INTO trip_trip_commitment VALUES (85, 10, NULL, 'U', false, 1, 80);
INSERT INTO trip_trip_commitment VALUES (86, 10, NULL, 'N', false, 1, 81);
INSERT INTO trip_trip_commitment VALUES (87, 9, NULL, 'U', false, 1, 82);
INSERT INTO trip_trip_commitment VALUES (88, 10, NULL, 'Y', true, 1, 83);
INSERT INTO trip_trip_commitment VALUES (89, 10, NULL, 'N', false, 1, 84);
INSERT INTO trip_trip_commitment VALUES (90, 9, NULL, 'Y', true, 1, 85);
INSERT INTO trip_trip_commitment VALUES (91, 10, NULL, 'Y', false, 1, 86);
INSERT INTO trip_trip_commitment VALUES (92, 9, NULL, 'U', false, 1, 87);
INSERT INTO trip_trip_commitment VALUES (93, 9, NULL, 'U', false, 1, 88);
INSERT INTO trip_trip_commitment VALUES (94, 9, NULL, 'Y', true, 1, 89);
INSERT INTO trip_trip_commitment VALUES (95, 10, NULL, 'Y', true, 1, 90);
INSERT INTO trip_trip_commitment VALUES (96, 10, NULL, 'U', false, 1, 91);
INSERT INTO trip_trip_commitment VALUES (97, 10, NULL, 'Y', false, 1, 92);
INSERT INTO trip_trip_commitment VALUES (98, 9, NULL, 'U', false, 1, 93);
INSERT INTO trip_trip_commitment VALUES (99, 9, NULL, 'Y', true, 1, 94);
INSERT INTO trip_trip_commitment VALUES (100, 9, NULL, 'Y', false, 1, 95);
INSERT INTO trip_trip_commitment VALUES (101, 9, NULL, 'N', false, 1, 96);
INSERT INTO trip_trip_commitment VALUES (102, 10, NULL, 'Y', true, 1, 97);
INSERT INTO trip_trip_commitment VALUES (103, 10, NULL, 'Y', false, 1, 98);
INSERT INTO trip_trip_commitment VALUES (104, 9, NULL, 'Y', true, 1, 99);
INSERT INTO trip_trip_commitment VALUES (105, 10, NULL, 'Y', true, 1, 100);
INSERT INTO trip_trip_commitment VALUES (106, 10, NULL, 'U', false, 1, 101);
INSERT INTO trip_trip_commitment VALUES (107, 10, NULL, 'Y', true, 1, 102);
INSERT INTO trip_trip_commitment VALUES (108, 9, NULL, 'Y', true, 1, 103);
INSERT INTO trip_trip_commitment VALUES (109, 10, NULL, 'Y', true, 1, 104);
INSERT INTO trip_trip_commitment VALUES (110, 10, NULL, 'Y', true, 1, 105);
INSERT INTO trip_trip_commitment VALUES (111, 10, NULL, 'U', false, 1, 106);
INSERT INTO trip_trip_commitment VALUES (112, 10, NULL, 'N', false, 1, 107);
INSERT INTO trip_trip_commitment VALUES (113, 10, NULL, 'Y', false, 1, 108);
INSERT INTO trip_trip_commitment VALUES (114, 9, NULL, 'Y', false, 1, 109);
INSERT INTO trip_trip_commitment VALUES (115, 9, NULL, 'U', false, 1, 110);
INSERT INTO trip_trip_commitment VALUES (116, 9, NULL, 'Y', false, 1, 111);
INSERT INTO trip_trip_commitment VALUES (117, 9, NULL, 'Y', false, 1, 112);
INSERT INTO trip_trip_commitment VALUES (118, 9, NULL, 'Y', true, 1, 113);
INSERT INTO trip_trip_commitment VALUES (119, 9, NULL, 'Y', true, 1, 114);
INSERT INTO trip_trip_commitment VALUES (120, 10, NULL, 'Y', true, 1, 115);
INSERT INTO trip_trip_commitment VALUES (121, 10, NULL, 'Y', true, 1, 116);
INSERT INTO trip_trip_commitment VALUES (8, 10, '', 'Y', false, 1, 117);
INSERT INTO trip_trip_commitment VALUES (122, 9, NULL, 'Y', true, 1, 118);
INSERT INTO trip_trip_commitment VALUES (123, 10, NULL, 'Y', true, 1, 119);
INSERT INTO trip_trip_commitment VALUES (124, 10, NULL, 'U', false, 1, 120);
INSERT INTO trip_trip_commitment VALUES (125, 9, NULL, 'Y', true, 1, 121);
INSERT INTO trip_trip_commitment VALUES (126, 10, NULL, 'Y', false, 1, 122);
INSERT INTO trip_trip_commitment VALUES (127, 9, NULL, 'U', false, 1, 123);
INSERT INTO trip_trip_commitment VALUES (128, 9, NULL, 'Y', false, 1, 124);
INSERT INTO trip_trip_commitment VALUES (129, 9, NULL, 'U', false, 1, 125);
INSERT INTO trip_trip_commitment VALUES (130, 9, NULL, 'Y', true, 1, 126);
INSERT INTO trip_trip_commitment VALUES (131, 9, NULL, 'Y', true, 1, 127);
INSERT INTO trip_trip_commitment VALUES (132, 10, NULL, 'U', false, 1, 128);
INSERT INTO trip_trip_commitment VALUES (133, 9, NULL, 'Y', false, 1, 129);
INSERT INTO trip_trip_commitment VALUES (134, 10, NULL, 'Y', true, 1, 130);
INSERT INTO trip_trip_commitment VALUES (135, 9, NULL, 'Y', false, 1, 131);
INSERT INTO trip_trip_commitment VALUES (136, 9, NULL, 'Y', true, 1, 132);
INSERT INTO trip_trip_commitment VALUES (137, 9, NULL, 'Y', false, 1, 133);
INSERT INTO trip_trip_commitment VALUES (138, 10, NULL, 'Y', false, 1, 134);
INSERT INTO trip_trip_commitment VALUES (139, 10, NULL, 'Y', true, 1, 135);
INSERT INTO trip_trip_commitment VALUES (140, 9, NULL, 'N', false, 1, 136);
INSERT INTO trip_trip_commitment VALUES (141, 10, NULL, 'N', false, 1, 137);
INSERT INTO trip_trip_commitment VALUES (142, 9, NULL, 'N', false, 1, 138);
INSERT INTO trip_trip_commitment VALUES (143, 10, NULL, 'N', false, 1, 139);
INSERT INTO trip_trip_commitment VALUES (144, 10, NULL, 'Y', false, 1, 140);
INSERT INTO trip_trip_commitment VALUES (145, 9, NULL, 'Y', true, 1, 141);
INSERT INTO trip_trip_commitment VALUES (146, 10, NULL, 'Y', true, 1, 142);
INSERT INTO trip_trip_commitment VALUES (147, 9, NULL, 'U', false, 1, 143);
INSERT INTO trip_trip_commitment VALUES (148, 9, NULL, 'Y', true, 1, 144);
INSERT INTO trip_trip_commitment VALUES (149, 10, NULL, 'Y', true, 1, 145);
INSERT INTO trip_trip_commitment VALUES (150, 10, NULL, 'Y', false, 1, 146);
INSERT INTO trip_trip_commitment VALUES (151, 9, NULL, 'Y', false, 1, 147);
INSERT INTO trip_trip_commitment VALUES (152, 9, NULL, 'N', false, 1, 148);
INSERT INTO trip_trip_commitment VALUES (153, 9, NULL, 'Y', true, 1, 149);
INSERT INTO trip_trip_commitment VALUES (154, 10, NULL, 'Y', true, 1, 150);
INSERT INTO trip_trip_commitment VALUES (155, 9, NULL, 'Y', true, 1, 151);
INSERT INTO trip_trip_commitment VALUES (156, 9, NULL, 'Y', false, 1, 152);
INSERT INTO trip_trip_commitment VALUES (157, 9, NULL, 'Y', false, 1, 153);
INSERT INTO trip_trip_commitment VALUES (158, 9, NULL, 'Y', false, 1, 154);
INSERT INTO trip_trip_commitment VALUES (159, 10, NULL, 'N', false, 1, 155);
INSERT INTO trip_trip_commitment VALUES (160, 10, NULL, 'N', false, 1, 156);
INSERT INTO trip_trip_commitment VALUES (161, 10, NULL, 'N', false, 1, 157);
INSERT INTO trip_trip_commitment VALUES (162, 9, NULL, 'Y', true, 1, 158);
INSERT INTO trip_trip_commitment VALUES (163, 10, NULL, 'Y', true, 1, 159);
INSERT INTO trip_trip_commitment VALUES (164, 10, NULL, 'Y', true, 1, 160);
INSERT INTO trip_trip_commitment VALUES (165, 10, NULL, 'Y', true, 1, 161);
INSERT INTO trip_trip_commitment VALUES (166, 9, NULL, 'Y', false, 1, 162);
INSERT INTO trip_trip_commitment VALUES (167, 9, NULL, 'N', false, 1, 163);
INSERT INTO trip_trip_commitment VALUES (168, 9, NULL, 'U', false, 1, 164);
INSERT INTO trip_trip_commitment VALUES (169, 10, NULL, 'Y', true, 1, 165);
INSERT INTO trip_trip_commitment VALUES (170, 10, NULL, 'U', false, 1, 166);
INSERT INTO trip_trip_commitment VALUES (171, 9, NULL, 'N', false, 1, 167);
INSERT INTO trip_trip_commitment VALUES (172, 9, NULL, 'U', false, 1, 168);
INSERT INTO trip_trip_commitment VALUES (173, 9, NULL, 'U', false, 1, 169);
INSERT INTO trip_trip_commitment VALUES (174, 10, NULL, 'Y', false, 1, 170);
INSERT INTO trip_trip_commitment VALUES (175, 9, NULL, 'Y', true, 1, 171);
INSERT INTO trip_trip_commitment VALUES (176, 9, NULL, 'Y', true, 1, 172);
INSERT INTO trip_trip_commitment VALUES (177, 9, NULL, 'N', false, 1, 173);
INSERT INTO trip_trip_commitment VALUES (178, 9, NULL, 'U', false, 1, 174);
INSERT INTO trip_trip_commitment VALUES (179, 10, NULL, 'Y', true, 1, 175);
INSERT INTO trip_trip_commitment VALUES (180, 10, NULL, 'Y', true, 1, 176);
INSERT INTO trip_trip_commitment VALUES (181, 9, NULL, 'N', false, 1, 177);
INSERT INTO trip_trip_commitment VALUES (182, 10, NULL, 'Y', false, 1, 178);
INSERT INTO trip_trip_commitment VALUES (183, 10, NULL, 'Y', true, 1, 179);
INSERT INTO trip_trip_commitment VALUES (184, 9, NULL, 'Y', true, 1, 180);
INSERT INTO trip_trip_commitment VALUES (185, 9, NULL, 'Y', false, 1, 181);
INSERT INTO trip_trip_commitment VALUES (186, 9, NULL, 'N', false, 1, 182);
INSERT INTO trip_trip_commitment VALUES (187, 10, NULL, 'N', false, 1, 183);
INSERT INTO trip_trip_commitment VALUES (188, 9, NULL, 'Y', true, 1, 184);
INSERT INTO trip_trip_commitment VALUES (189, 9, NULL, 'N', false, 1, 185);
INSERT INTO trip_trip_commitment VALUES (190, 10, NULL, 'N', false, 1, 186);
INSERT INTO trip_trip_commitment VALUES (191, 9, NULL, 'Y', true, 1, 187);
INSERT INTO trip_trip_commitment VALUES (192, 10, NULL, 'Y', false, 1, 188);
INSERT INTO trip_trip_commitment VALUES (193, 9, NULL, 'N', false, 1, 189);
INSERT INTO trip_trip_commitment VALUES (194, 10, NULL, 'N', false, 1, 190);
INSERT INTO trip_trip_commitment VALUES (195, 10, NULL, 'Y', false, 1, 191);
INSERT INTO trip_trip_commitment VALUES (196, 10, NULL, 'Y', true, 1, 192);
INSERT INTO trip_trip_commitment VALUES (197, 10, NULL, 'Y', true, 1, 193);
INSERT INTO trip_trip_commitment VALUES (198, 9, NULL, 'Y', false, 1, 194);
INSERT INTO trip_trip_commitment VALUES (199, 9, NULL, 'U', false, 1, 195);
INSERT INTO trip_trip_commitment VALUES (200, 10, NULL, 'Y', true, 1, 196);
INSERT INTO trip_trip_commitment VALUES (201, 10, NULL, 'Y', true, 1, 197);
INSERT INTO trip_trip_commitment VALUES (202, 9, NULL, 'N', false, 1, 198);
INSERT INTO trip_trip_commitment VALUES (203, 9, NULL, 'N', false, 1, 199);
INSERT INTO trip_trip_commitment VALUES (204, 9, NULL, 'N', false, 1, 200);
INSERT INTO trip_trip_commitment VALUES (205, 9, NULL, 'Y', true, 1, 201);
INSERT INTO trip_trip_commitment VALUES (206, 9, NULL, 'U', false, 1, 202);
INSERT INTO trip_trip_commitment VALUES (207, 9, NULL, 'N', false, 1, 203);
INSERT INTO trip_trip_commitment VALUES (208, 10, NULL, 'Y', true, 1, 204);
INSERT INTO trip_trip_commitment VALUES (209, 9, NULL, 'U', false, 1, 205);
INSERT INTO trip_trip_commitment VALUES (210, 10, NULL, 'N', false, 1, 206);
INSERT INTO trip_trip_commitment VALUES (211, 9, NULL, 'N', false, 1, 207);
INSERT INTO trip_trip_commitment VALUES (212, 9, NULL, 'Y', false, 1, 208);
INSERT INTO trip_trip_commitment VALUES (213, 9, NULL, 'Y', true, 1, 209);
INSERT INTO trip_trip_commitment VALUES (214, 10, NULL, 'N', false, 1, 210);
INSERT INTO trip_trip_commitment VALUES (215, 10, NULL, 'Y', false, 1, 211);
INSERT INTO trip_trip_commitment VALUES (216, 9, NULL, 'Y', true, 1, 212);
INSERT INTO trip_trip_commitment VALUES (217, 9, NULL, 'Y', false, 1, 213);
INSERT INTO trip_trip_commitment VALUES (218, 10, NULL, 'Y', true, 1, 214);
INSERT INTO trip_trip_commitment VALUES (219, 9, NULL, 'Y', true, 1, 215);
INSERT INTO trip_trip_commitment VALUES (220, 9, NULL, 'N', false, 1, 216);
INSERT INTO trip_trip_commitment VALUES (221, 10, NULL, 'Y', false, 1, 217);
INSERT INTO trip_trip_commitment VALUES (222, 10, NULL, 'Y', true, 1, 218);
INSERT INTO trip_trip_commitment VALUES (223, 9, NULL, 'Y', true, 1, 219);
INSERT INTO trip_trip_commitment VALUES (224, 10, NULL, 'Y', false, 1, 220);
INSERT INTO trip_trip_commitment VALUES (225, 10, NULL, 'Y', true, 1, 221);
INSERT INTO trip_trip_commitment VALUES (226, 10, NULL, 'Y', true, 1, 222);
INSERT INTO trip_trip_commitment VALUES (228, 9, NULL, 'N', false, 1, 224);
INSERT INTO trip_trip_commitment VALUES (229, 9, NULL, 'Y', true, 1, 225);
INSERT INTO trip_trip_commitment VALUES (230, 9, NULL, 'Y', true, 1, 226);
INSERT INTO trip_trip_commitment VALUES (231, 9, NULL, 'Y', true, 1, 227);
INSERT INTO trip_trip_commitment VALUES (232, 9, NULL, 'N', false, 1, 228);
INSERT INTO trip_trip_commitment VALUES (233, 10, NULL, 'U', false, 1, 229);
INSERT INTO trip_trip_commitment VALUES (234, 10, NULL, 'Y', false, 1, 230);
INSERT INTO trip_trip_commitment VALUES (235, 10, NULL, 'Y', false, 1, 231);
INSERT INTO trip_trip_commitment VALUES (236, 10, NULL, 'Y', false, 1, 232);
INSERT INTO trip_trip_commitment VALUES (237, 9, NULL, 'Y', false, 1, 233);
INSERT INTO trip_trip_commitment VALUES (238, 10, NULL, 'Y', false, 1, 234);
INSERT INTO trip_trip_commitment VALUES (239, 10, NULL, 'U', false, 1, 235);
INSERT INTO trip_trip_commitment VALUES (240, 10, NULL, 'N', false, 1, 236);
INSERT INTO trip_trip_commitment VALUES (241, 9, NULL, 'Y', true, 1, 237);
INSERT INTO trip_trip_commitment VALUES (242, 10, NULL, 'Y', false, 1, 238);
INSERT INTO trip_trip_commitment VALUES (243, 9, NULL, 'Y', false, 1, 239);
INSERT INTO trip_trip_commitment VALUES (244, 10, NULL, 'Y', true, 1, 240);
INSERT INTO trip_trip_commitment VALUES (245, 9, NULL, 'U', false, 1, 241);
INSERT INTO trip_trip_commitment VALUES (246, 9, NULL, 'U', false, 1, 242);
INSERT INTO trip_trip_commitment VALUES (247, 10, NULL, 'N', false, 1, 243);
INSERT INTO trip_trip_commitment VALUES (248, 9, NULL, 'N', false, 1, 244);
INSERT INTO trip_trip_commitment VALUES (249, 10, NULL, 'Y', true, 1, 245);
INSERT INTO trip_trip_commitment VALUES (250, 10, NULL, 'Y', false, 1, 246);
INSERT INTO trip_trip_commitment VALUES (251, 9, NULL, 'U', false, 1, 247);
INSERT INTO trip_trip_commitment VALUES (252, 10, NULL, 'Y', false, 1, 248);
INSERT INTO trip_trip_commitment VALUES (253, 9, NULL, 'U', false, 1, 249);
INSERT INTO trip_trip_commitment VALUES (254, 9, NULL, 'U', false, 1, 250);
INSERT INTO trip_trip_commitment VALUES (255, 9, NULL, 'N', false, 1, 251);
INSERT INTO trip_trip_commitment VALUES (256, 10, NULL, 'U', false, 1, 252);
INSERT INTO trip_trip_commitment VALUES (257, 9, NULL, 'U', false, 1, 253);
INSERT INTO trip_trip_commitment VALUES (258, 9, NULL, 'U', false, 1, 254);
INSERT INTO trip_trip_commitment VALUES (259, 10, NULL, 'N', false, 1, 255);
INSERT INTO trip_trip_commitment VALUES (261, 12, '', 'Y', false, 1, 256);
INSERT INTO trip_trip_commitment VALUES (262, 12, '', 'Y', false, 1, 257);
INSERT INTO trip_trip_commitment VALUES (264, 12, '', 'Y', false, 1, 259);
INSERT INTO trip_trip_commitment VALUES (3, 10, '', 'Y', false, 1, 260);
INSERT INTO trip_trip_commitment VALUES (265, 9, '6', 'Y', true, 1, 262);
INSERT INTO trip_trip_commitment VALUES (9, 9, '', 'Y', false, 1, 261);


--
-- Name: trip_trip_commitment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_trip_commitment_id_seq', 266, true);


--
-- Name: trip_trip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_trip_id_seq', 1, true);


--
-- Data for Name: trip_trip_payment_date; Type: TABLE DATA; Schema: public; Owner: jim
--

INSERT INTO trip_trip_payment_date VALUES (1, '2016-09-30', 250.00, false, 1);
INSERT INTO trip_trip_payment_date VALUES (2, '2016-10-19', 175.00, false, 1);
INSERT INTO trip_trip_payment_date VALUES (4, '2016-11-30', 175.00, false, 1);
INSERT INTO trip_trip_payment_date VALUES (5, '2017-01-20', 175.00, false, 1);
INSERT INTO trip_trip_payment_date VALUES (6, '2017-01-17', 175.00, false, 1);
INSERT INTO trip_trip_payment_date VALUES (7, '2017-03-01', NULL, true, 1);
INSERT INTO trip_trip_payment_date VALUES (3, '2016-11-09', 175.00, false, 1);


--
-- Name: trip_trip_payment_date_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jim
--

SELECT pg_catalog.setval('trip_trip_payment_date_id_seq', 7, true);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: trip_fund_raiser_item trip_fund_raiser_item_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_item
    ADD CONSTRAINT trip_fund_raiser_item_pkey PRIMARY KEY (id);


--
-- Name: trip_fund_raiser trip_fund_raiser_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser
    ADD CONSTRAINT trip_fund_raiser_pkey PRIMARY KEY (id);


--
-- Name: trip_fund_raiser_profit trip_fund_raiser_profit_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_profit
    ADD CONSTRAINT trip_fund_raiser_profit_pkey PRIMARY KEY (id);


--
-- Name: trip_fund_raiser_type trip_fund_raiser_type_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_type
    ADD CONSTRAINT trip_fund_raiser_type_pkey PRIMARY KEY (id);


--
-- Name: trip_payment trip_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_payment
    ADD CONSTRAINT trip_payment_pkey PRIMARY KEY (id);


--
-- Name: trip_student_fund_raiser trip_student_fund_rasier_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_student_fund_raiser
    ADD CONSTRAINT trip_student_fund_rasier_pkey PRIMARY KEY (id);


--
-- Name: trip_student trip_student_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_student
    ADD CONSTRAINT trip_student_pkey PRIMARY KEY (id);


--
-- Name: trip_trip_commitment trip_trip_commitment_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_commitment
    ADD CONSTRAINT trip_trip_commitment_pkey PRIMARY KEY (id);


--
-- Name: trip_trip_payment_date trip_trip_payment_date_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_payment_date
    ADD CONSTRAINT trip_trip_payment_date_pkey PRIMARY KEY (id);


--
-- Name: trip_trip_payment_date trip_trip_payment_date_trip_id_4e4565e6_uniq; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_payment_date
    ADD CONSTRAINT trip_trip_payment_date_trip_id_4e4565e6_uniq UNIQUE (trip_id, payment_date);


--
-- Name: trip_trip trip_trip_pkey; Type: CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip
    ADD CONSTRAINT trip_trip_pkey PRIMARY KEY (id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_group_name_a6ea08ec_like ON auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_0e939a4f; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_group_permissions_0e939a4f ON auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_8373b171; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_group_permissions_8373b171 ON auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_417f1b1c; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_permission_417f1b1c ON auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_0e939a4f; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_user_groups_0e939a4f ON auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_e8701ad4; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_user_groups_e8701ad4 ON auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_8373b171; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_user_user_permissions_8373b171 ON auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_e8701ad4; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_user_user_permissions_e8701ad4 ON auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX auth_user_username_6821ab7c_like ON auth_user USING btree (username varchar_pattern_ops);


--
-- Name: django_admin_log_417f1b1c; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX django_admin_log_417f1b1c ON django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_e8701ad4; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX django_admin_log_e8701ad4 ON django_admin_log USING btree (user_id);


--
-- Name: django_session_de54fa62; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX django_session_de54fa62 ON django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX django_session_session_key_c0390e0f_like ON django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: trip_fund_raiser_1fee2dc2; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_fund_raiser_1fee2dc2 ON trip_fund_raiser USING btree (fund_raiser_type_id);


--
-- Name: trip_fund_raiser_c65d32e5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_fund_raiser_c65d32e5 ON trip_fund_raiser USING btree (trip_id);


--
-- Name: trip_fund_raiser_item_3ffc6cba; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_fund_raiser_item_3ffc6cba ON trip_fund_raiser_item USING btree (fund_raiser_id);


--
-- Name: trip_fund_raiser_profit_3ffc6cba; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_fund_raiser_profit_3ffc6cba ON trip_fund_raiser_profit USING btree (fund_raiser_id);


--
-- Name: trip_fund_raiser_profit_c65d32e5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_fund_raiser_profit_c65d32e5 ON trip_fund_raiser_profit USING btree (trip_commitment_id);


--
-- Name: trip_payment_108bbef5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_payment_108bbef5 ON trip_payment USING btree (trip_commitment_id);


--
-- Name: trip_student_fund_rasier_108bbef5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_student_fund_rasier_108bbef5 ON trip_student_fund_raiser USING btree (trip_commitment_id);


--
-- Name: trip_student_fund_rasier_3ffc6cba; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_student_fund_rasier_3ffc6cba ON trip_student_fund_raiser USING btree (fund_raiser_id);


--
-- Name: trip_trip_commitment_30a811f6; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_trip_commitment_30a811f6 ON trip_trip_commitment USING btree (student_id);


--
-- Name: trip_trip_commitment_c65d32e5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_trip_commitment_c65d32e5 ON trip_trip_commitment USING btree (trip_id);


--
-- Name: trip_trip_payment_date_c65d32e5; Type: INDEX; Schema: public; Owner: jim
--

CREATE INDEX trip_trip_payment_date_c65d32e5 ON trip_trip_payment_date USING btree (trip_id);


--
-- Name: auth_group_permissions auth_group_permiss_permission_id_84c5c92e_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permiss_permission_id_84c5c92e_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permiss_content_type_id_2f476e4b_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permiss_content_type_id_2f476e4b_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_per_permission_id_1fbb5f2c_fk_auth_permission_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_per_permission_id_1fbb5f2c_fk_auth_permission_id FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_content_type_id_c4bce8eb_fk_django_content_type_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_content_type_id_c4bce8eb_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_fund_raiser trip_f_fund_raiser_type_id_4418d76b_fk_trip_fund_raiser_type_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser
    ADD CONSTRAINT trip_f_fund_raiser_type_id_4418d76b_fk_trip_fund_raiser_type_id FOREIGN KEY (fund_raiser_type_id) REFERENCES trip_fund_raiser_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_fund_raiser_profit trip_fun_trip_commitment_id_4fde6e9b_fk_trip_trip_commitment_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_profit
    ADD CONSTRAINT trip_fun_trip_commitment_id_4fde6e9b_fk_trip_trip_commitment_id FOREIGN KEY (trip_commitment_id) REFERENCES trip_trip_commitment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_fund_raiser_profit trip_fund_raiser_fund_raiser_id_0bb93c5a_fk_trip_fund_raiser_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_profit
    ADD CONSTRAINT trip_fund_raiser_fund_raiser_id_0bb93c5a_fk_trip_fund_raiser_id FOREIGN KEY (fund_raiser_id) REFERENCES trip_fund_raiser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_fund_raiser_item trip_fund_raiser_fund_raiser_id_1d585d59_fk_trip_fund_raiser_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser_item
    ADD CONSTRAINT trip_fund_raiser_fund_raiser_id_1d585d59_fk_trip_fund_raiser_id FOREIGN KEY (fund_raiser_id) REFERENCES trip_fund_raiser(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_fund_raiser trip_fund_raiser_trip_id_e0c22591_fk_trip_trip_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_fund_raiser
    ADD CONSTRAINT trip_fund_raiser_trip_id_e0c22591_fk_trip_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trip(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_payment trip_pay_trip_commitment_id_fe5fd657_fk_trip_trip_commitment_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_payment
    ADD CONSTRAINT trip_pay_trip_commitment_id_fe5fd657_fk_trip_trip_commitment_id FOREIGN KEY (trip_commitment_id) REFERENCES trip_trip_commitment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_student_fund_raiser trip_stu_trip_commitment_id_1f6e48ae_fk_trip_trip_commitment_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_student_fund_raiser
    ADD CONSTRAINT trip_stu_trip_commitment_id_1f6e48ae_fk_trip_trip_commitment_id FOREIGN KEY (trip_commitment_id) REFERENCES trip_trip_commitment(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_student_fund_raiser trip_studen_fund_raiser_id_516b7203_fk_trip_fund_raiser_item_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_student_fund_raiser
    ADD CONSTRAINT trip_studen_fund_raiser_id_516b7203_fk_trip_fund_raiser_item_id FOREIGN KEY (fund_raiser_id) REFERENCES trip_fund_raiser_item(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_trip_commitment trip_trip_commitment_student_id_b2f5dfc4_fk_trip_student_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_commitment
    ADD CONSTRAINT trip_trip_commitment_student_id_b2f5dfc4_fk_trip_student_id FOREIGN KEY (student_id) REFERENCES trip_student(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_trip_commitment trip_trip_commitment_trip_id_c748a55a_fk_trip_trip_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_commitment
    ADD CONSTRAINT trip_trip_commitment_trip_id_c748a55a_fk_trip_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trip(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: trip_trip_payment_date trip_trip_payment_date_trip_id_d74e81ca_fk_trip_trip_id; Type: FK CONSTRAINT; Schema: public; Owner: jim
--

ALTER TABLE ONLY trip_trip_payment_date
    ADD CONSTRAINT trip_trip_payment_date_trip_id_d74e81ca_fk_trip_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trip(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

