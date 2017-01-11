create  view "trip_trip_commitment_vw" as
select s."id",
       tc."id" as "trip_commitment_id",
       s."first_name",
       s."last_name",
       s."email_1",
       s."email_2",
       s."phone_1",
       s."phone_2",
       s."svid",
       tc."student_grade",
       tc."period",
       tc."going_on_trip",
       tc."purchase_insurance",
       tc."trip_id"
from "trip_student" as s
  inner join "trip_trip_commitment" as tc on (s."id" = "student_id");

create view "trip_fund_raiser_profit_vw" as
select  frp."trip_commitment_id",
        fr."id",
        fr."description" as "fund_raiser_description",
        coalesce(sum(coalesce(frp."profit",0.00)),0.00) as "total_profit"
from "trip_fund_raiser" as fr
  inner join "trip_fund_raiser_profit" as frp on (fr."id" = frp."fund_raiser_id")
group by frp."trip_commitment_id",
        fr."id",
        fr."description";

create view "trip_fund_raiser_item_profit_vw" as
select sfr."trip_commitment_id",
       fr."id" as "fund_raiser_id",
       fr."description" as "fund_raiser_description",
       sum(coalesce(sfr.quantity_sold,0.00) * coalesce(fri.profit,fri.cost*fri.profit_percentage)) as "total_profit"
from "trip_fund_raiser_item" as fri
  inner join "trip_fund_raiser" as fr on (fri."fund_raiser_id" = fr."id")
  inner join "trip_student_fund_raiser" as sfr on (fri."id" = sfr."fund_raiser_id")
group by sfr."trip_commitment_id",
       fr."id",
       fr."description";

create view "trip_fund_raiser_item_detail_vw" as
select tc."trip_commitment_id",
       fri."id" as "fund_raiser_item_id",
       sfr."id" as "student_fund_raiser_id",
       fr."id" as "fund_raiser_id",
       tc."first_name",
       tc."last_name",
       fri."description" as "item_description",
       fri."display_order",
       fri."cost",
       (fri."cost" * sfr."quantity_sold") as "sub_total",
       fri."profit",
       fri."profit_percentage",
       (fri."profit" * sfr."quantity_sold") as profit_total,
       (fri."cost" * sfr."quantity_sold" * fri.profit_percentage) as profit_percentage_total,
       fr."description" as "fund_raiser",
       sfr."quantity_sold"
from "trip_fund_raiser_item" as fri
  inner join "trip_fund_raiser" as fr on (fri."fund_raiser_id" = fr."id")
  inner join "trip_student_fund_raiser" as sfr on (fri."id" = sfr."fund_raiser_id")
  inner join "trip_trip_commitment_vw" as tc on (sfr."trip_commitment_id" = tc."trip_commitment_id");
  
create view "trip_all_fund_raiser_profit_vw" as
select "trip_commitment_id",
       'Item' as "fund_raiser_type",
       "fund_raiser_id",
       "fund_raiser_description",
       "total_profit"
from "trip_fund_raiser_item_profit_vw"
union
select "trip_commitment_id",
       'Single',
       "id",
       "fund_raiser_description",
       "total_profit"
from "trip_fund_raiser_profit_vw";

create view "trip_total_fund_raiser_profit_vw" as
select  tc."trip_commitment_id",
        sum(coalesce(frp."total_profit",0.00)) + sum(coalesce(frip."total_profit",0.00)) as "profit"
from "trip_trip_commitment_vw" as tc
  left outer join "trip_fund_raiser_profit_vw" as frp on (tc."trip_commitment_id" = frp."trip_commitment_id")
  left outer join "trip_fund_raiser_item_profit_vw" as frip on (tc."trip_commitment_id" = frip."trip_commitment_id")
group by tc."trip_commitment_id";

create view "trip_fund_raiser_detail_vw" as
select frp.id as "fund_raiser_profit_id",
       tc."trip_commitment_id",
       frp."fund_raiser_id",
       tc."first_name",
       tc."last_name",
       frp."profit",
       frp."date_entered",
       tfr."description" as "fund_raiser_description",
       tfr."profit_percentage" 
from "trip_trip_commitment_vw" as tc
  inner join "trip_fund_raiser_profit" as frp on (tc."trip_commitment_id" = frp."trip_commitment_id")
  inner join "trip_fund_raiser" as tfr on (frp."fund_raiser_id" = tfr."id");

create view "trip_trip_current_payment_due" as
select tpd."trip_id",
       "current_trip",
       "current_payment_date",
       (case when maxtpd."final_payment" = 't' then trip."trip_cost"
            else "payment_due"
       end) as "current_amount_due"
from "trip_trip" as trip
  inner join (select "trip_id", sum(coalesce("payment_amount",0.00)) as "payment_due" 
              from "trip_trip_payment_date" 
              where "payment_date" <= current_date
              group by "trip_id") as tpd 
        on (trip."id" = tpd."trip_id")
  inner join (select "trip_id", "payment_date" as "current_payment_date", "final_payment"
              from "trip_trip_payment_date"
              where ("payment_date") in
                  (select max(payment_date) "current_payment_date" 
                  from "trip_trip_payment_date" 
                  where "payment_date" <= current_date 
                  group by "trip_id")) as maxtpd 
        on (trip."id" = maxtpd."trip_id");

create view "trip_trip_commitment_dashboard_vw" as
select  tc."id",
        tc."trip_commitment_id",
        tc."last_name" ||', '|| tc."first_name" as full_name,
        tc."student_grade",
        tc."period",
        tc."going_on_trip",
        tc."purchase_insurance",
        tc."email_1",
        tc."email_2",
        tc."phone_1",
        tc."phone_2",
        trip."description" as trip_description,
        trip."trip_cost",
        trip."insurance_cost",
        trip."current_trip",
        coalesce(trip_payment."total_payment",0.00) as "total_payment",
        coalesce(frp."profit",0) as "total_fund_raiser_profit",
        cpd."current_amount_due",
        cpd."current_payment_date",
        (cpd."current_amount_due" - coalesce(trip_payment."total_payment",0) - coalesce(frp."profit",0)) as "current_payment_due",
        (trip."trip_cost" - coalesce(trip_payment."total_payment",0) - coalesce(frp."profit",0)) as "trip_balance",
        (case when (cpd."current_amount_due" - coalesce(trip_payment."total_payment",0) - coalesce(frp."profit",0)) <= 0 then 'OK'
              else 'LOW'
         end) as "account_up_to_date"
from "trip_trip_commitment_vw" tc
  inner join "trip_trip" trip on (tc.trip_id = trip.id)
  inner join "trip_trip_current_payment_due" as cpd on (tc."trip_id" = cpd."trip_id")
  left outer join (select "trip_commitment_id", sum("payment_amount") as total_payment from "trip_payment" as x group by "trip_commitment_id") as trip_payment on (tc."trip_commitment_id" = trip_payment."trip_commitment_id")
  left outer join "trip_total_fund_raiser_profit_vw" as frp on (tc."trip_commitment_id" = frp."trip_commitment_id")
where trip."current_trip" = 't'
;
