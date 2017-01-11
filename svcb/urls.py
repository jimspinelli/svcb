"""svcb URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.10/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
#from django.conf.urls import include,url
#from django.contrib import admin
from django.conf import settings
#from django.views import static
from django.conf.urls import include,url
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

#from trip.views import (Trip_Commitment,StudentUpdateView,student_new)
import trip.views

#from trip import views

#admin.autodiscover()

urlpatterns = [
    #url(r'^$', Trip_Commitment.as_view(), name='singletableview'),
    url(r'^$', trip.views.HomePageView.as_view(), name='home'),
    url(r'^student$', trip.views.StudentList.as_view(), name='student_list'),
    url(r'^student/(?P<pk>\d+)/$', trip.views.StudentDetail.as_view(), name='student_detail'),
    url(r'^student/add/$', trip.views.StudentCreateView.as_view(), name='add_student_and_tripcommitment'),
    url(r'^student/edit/(?P<pk>\d+)/$', trip.views.StudentUpdateView.as_view(), name='edit_student_and_tripcommitment'),
    url(r'^trip_commitment/$', trip.views.TripCommitmentList.as_view(), name='tripcommitment_list'),
    url(r'^trip_commitment/(?P<pk>\d+)/$', trip.views.TripCommitmentDetail.as_view(), name='tripcommitment_detail'),
    url(r'^sfr/(?P<id>\d+)/$', trip.views.ListFund_RaiserView.as_view(), name='list_student_fund_raiser'),
    url(r'^sfr/detail/(?P<tcid>\d+)/(?P<frid>\d+)/$', trip.views.ListFund_Raiser_DetailView.as_view(), name='fund_raiser_detail'),
    url(r'^sfri/detail/(?P<tcid>\d+)/(?P<frid>\d+)/$',trip.views.ListFund_Raiser_Item_DetailView.as_view(), name='fund_raiser_item_detail'),
    url(r'^dashboard$', trip.views.ListTrip_CommitmentView.as_view(),name='trip_commitment-list',),
    url(r'^new$', trip.views.CreateTrip_CommitmentView.as_view(),name='trip_commitment-new',),
    #url(r'^student/edit/(?P<pk>\d+)/$', trip.views.UpdateStudent.as_view(),name='student-edit',),
    url(r'^edit/(?P<pk>\d+)/$', trip.views.UpdateTrip_CommitmentView.as_view(),name='trip_commitment-edit',),
    url(r'^payment/edit/(?P<pk>\d+)/$', trip.views.UpdatePaymentView.as_view(),name='payment-edit',),
    url(r'^jim/(?P<id>\d+)/$', trip.views.ListPaymentView.as_view(),name='payment-list',),
    #url(r'^payment/new$', trip.views.CreatePaymentView,name='payment-new',),
    #this works, trying to use widget
    url(r'^payment/new$', trip.views.CreatePaymentView.as_view(),name='payment-new',),
    url(r'^payment/(?P<id>\d+)/$', trip.views.CreateListPaymentView.as_view(),name='createlistpaymentview',),
    #url(r'^trip/', include('trip.urls')),
    url(r'^admin/', admin.site.urls),
]

urlpatterns += staticfiles_urlpatterns()

if settings.DEBUG:
    import debug_toolbar
#    urlpatterns += patterns('',
    urlpatterns += [
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ]
