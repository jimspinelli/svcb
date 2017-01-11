from django.contrib import admin

# Register your models here.
from .models import Trip, Fund_Raiser_Type, Fund_Raiser, Trip_Payment_Date

#class ChoiceInline(admin.TabularInline):
#    model = Trip
#    extra = 1

class Fund_Raiser_TypeInline(admin.TabularInline):
    model = Fund_Raiser_Type
    extra = 0

class Fund_RaiserInline(admin.TabularInline):
    model = Fund_Raiser
    classes = ['collapse']
    verbose_name="fund Raiser"
    extra = 0
    inlines = [
        Fund_Raiser_TypeInline
    ]
    def formatted_profit(self, obj):
        return '$%.2f' % obj.profit
    fieldsets = [
        ('Fund Raisers', {'classes':('collapse',),'fields':('description','fund_raiser_date','profit','profit_percentage')})
    ]
    list_display = ('description', 'fund_raiser_date','formatted_profit','profit_percentage')

class Trip_Payment_Date(admin.TabularInline):
    model = Trip_Payment_Date
    classes = ['collapse','collapsed']
    extra = 0

class TripAdmin(admin.ModelAdmin):
    def formatted_trip_cost(self, obj):
        return '$%.2f' % obj.trip_cost
    fieldsets = [
        ('Trip Information', {'fields': (('description','current_trip','school_year'),('trip_cost','insurance_cost'),('trip_start_date','trip_end_date'))}),
        ('Trip Coordinator', {'classes':('collapse',),'fields': (('trip_coordinator','trip_coordinator_email'),)},),
        ('Trip Tour Company Information', {'classes':('collapse',),'fields': ('trip_company',('trip_company_contact','trip_company_phone','trip_company_email'))}),
    ]
    list_display = ('description', 'formatted_trip_cost')
    inlines = [
        Fund_RaiserInline,
        Trip_Payment_Date
    ]

class Fund_Raiser_TypeAdmin(admin.ModelAdmin):
    fieldsets = [
        (None, {'fields': ('description','super_group')}),
    ]
    list_display = ('description','super_group')



    
#class Fund_RaiserAdmin(admin.ModelAdmin):
#    fieldsets = [
#        (None, {'fields': ('description','fund_raiser_date','profit','profit_percentage')}),
#    ]
##    list_display = ("description","_trips")
##    search_fields = [
#    inlines = [
#        TripInline,
##        Fund_Raiser_TypeInline,
#    ]
#    def _trips(self,obj):
#        return obj.trips.all().count()

admin.site.register(Trip,TripAdmin)
admin.site.register(Fund_Raiser_Type,Fund_Raiser_TypeAdmin)
#admin.site.register(Trip_Payment_Date,Trip_Payment_DateAdmin)
#admin.site.register(Fund_Raiser,Fund_RaiserAdmin)
