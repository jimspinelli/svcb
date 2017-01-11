import datetime

from django.db import models
from django.utils import timezone
from django.core.urlresolvers import reverse

# Create your models here.
class Trip(models.Model):
    class Meta:
        verbose_name="Trip"
        verbose_name_plural="Trips"
    id = models.AutoField(primary_key=True)
    description = models.CharField(max_length=200)
    trip_cost = models.DecimalField("trip Cost",max_digits=6, decimal_places=2)
    insurance_cost = models.DecimalField("insurance Cost",max_digits=6, decimal_places=2)
    school_year = models.SmallIntegerField(blank=True,null=True)
    current_trip = models.BooleanField("current Trip?",default='False')
    trip_start_date = models.DateField("start Date",blank=True,null=True)
    trip_end_date = models.DateField("end Date",blank=True,null=True)
    trip_company = models.CharField("company",max_length=200,blank=True,null=True)
    trip_company_contact = models.CharField("contact",max_length=200,blank=True,null=True)
    trip_company_phone = models.CharField("contact Phone",max_length=15,blank=True,null=True)
    trip_company_email = models.CharField("contact Email",max_length=75,blank=True,null=True)
    trip_coordinator = models.CharField("coordinator",max_length=200,blank=True,null=True)
    trip_coordinator_email = models.CharField("coordinator Email",max_length=75,blank=True,null=True)
    def __str__(self):
        return self.description
    #date_created = models.DateTimeField
    #who_created fk to user ???
    #date_updated = models.DateTimeField
    #who_updated fk to user???

class Fund_Raiser_Type(models.Model):
    class Meta:
        verbose_name="Fund Raiser Type"
        verbose_name_plural="Fund Raiser Types"
        ordering=("description",)
    id = models.AutoField(primary_key=True)
    description = models.CharField(max_length=75)
    super_group = models.CharField("super Group",max_length=75,default='Aramark')
    def __str__(self):
        return self.description

class Fund_Raiser(models.Model):
    class Meta:
        verbose_name="Fund Raiser"
        verbose_name_plural="Fund Raisers"
    id = models.AutoField(primary_key=True)
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE)
    description = models.CharField("fund Raiser",max_length=200)
    fund_raiser_date = models.DateField("fund Raiser Date")
    fund_raiser_type = models.ForeignKey(Fund_Raiser_Type,verbose_name="fund Raiser Type", on_delete=models.CASCADE)
    profit = models.DecimalField("profit",max_digits=6, decimal_places=2,blank=True,null=True)
    profit_percentage = models.DecimalField("profit Percentage",max_digits=5, decimal_places=2,blank=True,null=True)
    def __str__(self):
        return self.description

class Fund_Raiser_Item(models.Model):
    class Meta:
        verbose_name="Fund_Raiser_Item"
        verbose_name_plural="Fund_Raiser_Items"
    id = models.AutoField(primary_key=True)
    fund_raiser=models.ForeignKey(
        Fund_Raiser,
        related_name="fund_raiser_items",
        on_delete=models.CASCADE)
    description=models.CharField("Fund Raiser Item",max_length=50)
    display_order=models.IntegerField("Display Order")
    cost=models.DecimalField("payment_Amount",max_digits=6, decimal_places=2,blank=True,null=True)
    profit=models.DecimalField("payment_Amount",max_digits=6, decimal_places=2,blank=True,null=True)
    profit_percentage=models.IntegerField("Profit Percentage",blank=True,null=True)
    def __str__(self):
        return self.description

class Student(models.Model):
    class Meta:
        verbose_name="Student"
        verbose_name_plural="Students"
    id = models.AutoField(primary_key=True)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    svid = models.CharField("SV ID",max_length=10,blank=True,null=True)
    email_1 = models.CharField(max_length=75,blank=True,null=True)
    email_2 = models.CharField(max_length=75,blank=True,null=True)
    phone_1 = models.CharField(max_length=15,blank=True,null=True)
    phone_2 = models.CharField(max_length=15,blank=True,null=True)
    def __str__(self):
        return ' '.join([self.last_name, self.first_name])
        #return self.last_name, self.first_name
    #def get_absolute_url(self):
    #    return reverse('trip_commitment-view', kwargs={'pk': self.id})
    @models.permalink
    def get_absolute_url(self):
        return('edit_student_and_tripcommitment',[self.pk])
    
    @property
    def full_name(self):
        return '%s, %s' % (self.last_name, self.first_name)

class Trip_Commitment(models.Model):
    class Meta:
        verbose_name="Trip Commitment"
        verbose_name_plural="Trip Commitments"
    id = models.AutoField(primary_key=True)
    student = models.ForeignKey(
        Student,
        related_name="students",
        on_delete=models.CASCADE)
    student_grade = models.IntegerField("Grade",choices=((8,8),(9,9),(10,10),(11,11),(12,12)))
    period = models.CharField(max_length=2,blank=True,null=True)
    trip = models.ForeignKey(
        Trip,
        related_name="trips",
        on_delete=models.CASCADE)
    GOING_CHOICES = (
        ('U','Unknown'),
        ('Y','Yes'),
        ('N','No'),
    )
    going_on_trip = models.CharField(max_length=1, default='U',choices=GOING_CHOICES)
    purchase_insurance = models.BooleanField(default=0)
    def __str__(self):
        return self.going_on_trip
    @models.permalink
    def get_absolute_url(self):
        return ('trip_commitment_detail', [self.pk])

class Trip_Payment_Date(models.Model):
    id = models.AutoField(primary_key=True)
    trip = models.ForeignKey(
        Trip,
        related_name="trip_payment_dates",
        on_delete=models.CASCADE)
    payment_date=models.DateField("payment Date")
    payment_amount=models.DecimalField("payment Amount",max_digits=6, decimal_places=2,blank=True,null=True)
    final_payment=models.NullBooleanField(default=0,blank=True,null=True)
    class Meta:
        verbose_name="Trip Payment Date"
        verbose_name_plural="Trip Payment Dates"
        unique_together=('trip','payment_date')    
    def __str__(self):
        return self.payment_date

class Payment(models.Model):
    id = models.AutoField(primary_key=True)
    trip_commitment = models.ForeignKey(
        Trip_Commitment,
        related_name="trip_payments",
        on_delete=models.CASCADE)
    payment_date=models.DateField("payment Date",blank=True,null=True)
    payment_amount=models.DecimalField("payment Amount",max_digits=6, decimal_places=2)
    check_number=models.CharField("check Number",max_length=20)
    deposit_date=models.DateField("deposit Date",blank=True,null=True)
    def __str__(self):
        return self.payment_amount
    def get_absolute_url(self):
        #return reverse('trip_commitment-list')
        return reverse('createlistpaymentview', kwargs={'id': self.trip_commitment_id})
    
class Student_Fund_Raiser(models.Model):
    id = models.AutoField(primary_key=True)
    trip_commitment=models.ForeignKey(
        Trip_Commitment,
        related_name="student_fund_raiser",
        on_delete=models.CASCADE)
    fund_raiser=models.ForeignKey(
        Fund_Raiser_Item,
        related_name="fund_raiser_items",
        on_delete=models.CASCADE)
    quantity_sold=models.IntegerField("quantity_Sold")
    def __str__(self):
        return self.quantity_sold

class Trip_Fund_Raiser_Profit(models.Model):
    trip_commitment_id = models.IntegerField(primary_key=True)
    fund_raiser_type = models.CharField(max_length=10)
    fund_raiser_id = models.IntegerField()
    fund_raiser_description = models.CharField("Fund Raiser",max_length=200)
    total_profit = models.DecimalField("Total Profit", max_digits=6, decimal_places=2)
    def __str__(self):
        return self.fund_raiser_description
    class Meta:
        verbose_name="Trip Fund Raiser Profits"
        managed = False
        db_table = 'trip_all_fund_raiser_profit_vw'

class Trip_Fund_Raiser_Detail(models.Model):
    fund_raiser_profit_id = models.IntegerField(primary_key=True)
    trip_commitment_id = models.IntegerField()
    fund_raiser_id = models.IntegerField()
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    profit = models.DecimalField("profit",max_digits=6, decimal_places=2)
    date_entered = models.DateField()
    fund_raiser_description = models.CharField(max_length=200)
    profit_percentage = models.DecimalField("profit",max_digits=5, decimal_places=2)
    def __str__(self):
        return self.fund_raiser_description
    class Meta:
        verbose_name="Trip Fund Raiser Detail"
        managed = False
        db_table = 'trip_fund_raiser_detail_vw'

class Trip_Fund_Raiser_Item_Detail(models.Model):
    trip_commitment_id = models.IntegerField()
    fund_raiser_item_id = models.IntegerField(primary_key=True)
    student_fund_raiser_id = models.IntegerField()
    fund_raiser_id = models.IntegerField()
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    item_description = models.CharField(max_length=50)
    display_order= models.IntegerField()
    cost = models.DecimalField("cost",max_digits=6, decimal_places=2)
    sub_total = models.DecimalField("profit",max_digits=6, decimal_places=2)
    profit = models.DecimalField("profit",max_digits=6, decimal_places=2)
    profit_percentage = models.IntegerField()
    profit_total = models.DecimalField("profit",max_digits=6, decimal_places=2)
    profit_percentage_total = models.DecimalField("profit",max_digits=6, decimal_places=2)
    fund_raiser = models.CharField(max_length=200)
    quantity_sold = models.IntegerField()
    def __str__(self):
        return self.item_description
    class Meta:
        verbose_name="Trip Fund Raiser Item Detail"
        managed = False
        db_table = 'trip_fund_raiser_item_detail_vw'

class Fund_Raiser_Profit(models.Model):
    id = models.AutoField(primary_key=True)
    trip_commitment = models.ForeignKey(
        Trip_Commitment,
        related_name="fund_raiser_trip",
        on_delete=models.CASCADE)
    fund_raiser = models.ForeignKey(
        Fund_Raiser,
        related_name="fund_raiser_fund",
        on_delete=models.CASCADE)
    profit=models.DecimalField("profit",max_digits=6, decimal_places=2)
    date_entered=models.DateTimeField("date_Entered",auto_now_add=True)
    def __str__(self):
        return self.profit
    
class Trip_Commitment_Dashboard(models.Model):
    id=models.AutoField(primary_key=True)
    trip_commitment_id=models.IntegerField()
    full_name=models.CharField(max_length=510)
    student_grade=models.IntegerField()
    period=models.CharField(max_length=2)
    GOING_CHOICES = (
        ('U','Unknown'),
        ('Y','Yes'),
        ('N','No'),
    )
    going_on_trip = models.CharField(max_length=1, default='U',choices=GOING_CHOICES)
    purchase_insurance=models.BooleanField(default=0)
    email_1 = models.CharField(max_length=75,blank=True,null=True)
    email_2 = models.CharField(max_length=75,blank=True,null=True)
    phone_1 = models.CharField(max_length=15,blank=True,null=True)
    phone_2 = models.CharField(max_length=15,blank=True,null=True)
    trip_description=models.CharField(max_length=200)
    trip_cost=models.DecimalField(max_digits=6, decimal_places=2)
    insurance_cost=models.DecimalField(max_digits=6, decimal_places=2)
    current_trip=models.BooleanField(default=0)
    total_payment=models.DecimalField("Total Payments",max_digits=6, decimal_places=2)
    total_fund_raiser_profit=models.DecimalField("Total Fund Raiser Profits",max_digits=6, decimal_places=2)
    current_amount_due=models.DecimalField(max_digits=6, decimal_places=2)
    current_payment_date=models.DateField()
    current_payment_due=models.DecimalField(max_digits=6, decimal_places=2)
    trip_balance=models.DecimalField(max_digits=6, decimal_places=2)
    account_up_to_date=models.CharField(max_length=3)
    class Meta:
        verbose_name="Trip Commitment Dashboard"
        verbose_name_plural="Trip Commitments Dashboard"
        managed = False
        db_table = 'trip_trip_commitment_dashboard_vw'
    def __str__(self):
        return self.full_name
    def get_absolute_url(self):
        return reverse('trip_commitment-view', kwargs={'pk': self.id})

class Trip_current_payment_due(models.Model):
    #id=models.AutoField(primary_key=True)
    trip_id=models.AutoField(primary_key=True)
    current_trip=models.BooleanField(default=0)
    current_payment_date=models.DateField()
    current_amount_due=models.DecimalField(max_digits=6, decimal_places=2)
    class Meta:
        verbose_name="Trip Current Payment Due"
        managed = False
        db_table = 'trip_trip_current_payment_due'
    def __str__(self):
        return self.full_name
    
