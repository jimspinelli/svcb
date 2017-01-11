# coding: utf-8
import django_tables2 as tables
from django_tables2.utils import A # alias for Accessor
from .models import Trip_Commitment_Dashboard,Trip_Fund_Raiser_Profit,Trip_Fund_Raiser_Detail,Trip_Fund_Raiser_Item_Detail

class CurrencyColumn(tables.Column):
    def render(self,value):
        return "$%.2f" % float(value)

class AccountUpToDateColumn(tables.Column):
    def render(self, value, record):
        if record.going_on_trip == 'N':
            self.attrs = {"td": {"bgcolor":"DarkGray"}}
        elif record.going_on_trip == 'Y' and record.trip_balance < 0:
            self.attrs ={"td": {"bgcolor":"LightGreen"}}
        elif record.account_up_to_date == 'LOW':
            self.attrs ={"td": {"bgcolor":"Violet"}}
        else:
            self.attrs ={"td": {"bgcolor":"transparent"}}
        return u"%s" % (record.account_up_to_date)

class PaymentTable(tables.Table):
    payment_date = tables.Column(verbose_name='Payment Date')
    payment_amount = CurrencyColumn(verbose_name='Payment Amount')
    check_number = tables.Column(verbose_name='Check Number')
    deposit_date = tables.Column(verbose_name='Deposit Date')
    class Meta:
        model = Trip_Commitment_Dashboard
        order_by=("student_grade","full_name",)
        # This attribute identifies fields to display
        fields = ('payment_date',
                  'payment_amount',
                  'check_number',
                  'deposit_date')
        sequence = ('payment_amount',
                    'payment_date',
                    'check_number',
                    'deposit_date')

class Fund_Raiser_DetailTable(tables.Table):
    fund_raiser_profit_id = tables.Column()
    first_name = tables.Column(verbose_name='First Name')
    last_name = tables.Column(verbose_name='Last Name')
    profit = tables.Column(verbose_name='Profit')
    date_entered = tables.Column(verbose_name='Date')
    fund_raiser_description= tables.Column(verbose_name='Fund Raiser Description')
    profit_percentage = tables.Column(verbose_name = 'Profit Percentage')
    class Meta:
        model = Trip_Fund_Raiser_Detail
        fields = ('fund_raiser_description',
                  'profit',
                  'date_entered',
                  'fund_raiser_profit_id')

class Fund_Raiser_Item_DetailTable(tables.Table):
    trip_commitment_id = tables.Column()
    fund_raiser_item_id= tables.Column()
    student_fund_raiser_id= tables.Column()
    fund_raiser_id= tables.Column()
    first_name= tables.Column()
    last_name= tables.Column()
    item_description= tables.Column()
    display_order= tables.Column()
    cost= tables.Column()
    sub_total= tables.Column()
    profit= tables.Column()
    profit_percentage= tables.Column()
    profit_total= tables.Column()
    profit_percentage_total= tables.Column()
    fund_raiser= tables.Column()
    quantity_sold= tables.Column()
    class Meta:
        model = Trip_Fund_Raiser_Item_Detail
        fields = ()
        
class Student_Fund_RaiserTable(tables.Table):
    trip_commitment_id = tables.Column()
    fund_raiser_type = tables.Column()
    fund_raiser_id = tables.Column()
    fund_raiser_description = tables.Column(verbose_name='Fund Raiser')
    total_profit = CurrencyColumn(verbose_name='Profit')
    class Meta:
        model = Trip_Fund_Raiser_Profit
        fields = ('fund_raiser_description','total_profit')
        
class Trip_CommitmentTable(tables.Table):
    full_name = tables.LinkColumn('edit_student_and_tripcommitment',args=[A('pk')])
    student_grade = tables.Column(verbose_name='Grade')
    going_on_trip = tables.Column(verbose_name='Going on Trip?')
    #purchase_insurance = tables.BooleanColumn(verbose_name="Purchase Insurance?")
    purchase_insurance = tables.Column(verbose_name="Purchase Insurance?")
    total_payment=tables.LinkColumn('createlistpaymentview', args=(A('trip_commitment_id'),))
    total_fund_raiser_profit=tables.LinkColumn('list_student_fund_raiser', args=(A('trip_commitment_id'),))
    current_payment_due=CurrencyColumn(verbose_name='Current Payment Due')
    trip_balance=CurrencyColumn(verbose_name='Trip Balance')
    account_up_to_date=AccountUpToDateColumn(verbose_name='Account Up To Date?')
    class Meta:
        model = Trip_Commitment_Dashboard
        order_by=("student_grade","full_name",)
        # This attribute identifies fields to display
        fields = ('full_name',
                  'student_grade',
                  'going_on_trip',
                  'purchase_insurance',
                  'total_payment',
                  'total_fund_raiser_profit',
                  'trip_balance',
                  'account_up_to_date')
        # This attribute identifies the order in which to display fields
        sequence = ('full_name',
                  'student_grade',
                  'trip_balance',
                  'current_payment_due',
                  'total_payment',
                  'total_fund_raiser_profit',
                  'account_up_to_date',
                  'going_on_trip',
                  'purchase_insurance',
                   )
    
        
class ThemedTrip_CommitmentTable(Trip_CommitmentTable):
    class Meta:
        attrs = {'class': 'paleblue'}
    
class ThemedStudent_Fund_RaiserTable(Student_Fund_RaiserTable):
    class Meta:
        attrs = {'class': 'paleblue'}

class ThemedFund_Raiser_DetailTable(Fund_Raiser_DetailTable):
    class Meta:
        attrs = {'class': 'paleblue'}

class ThemedFund_Raiser_Item_DetailTable(Fund_Raiser_Item_DetailTable):
    class Meta:
        attrs = {'class': 'paleblue'}
