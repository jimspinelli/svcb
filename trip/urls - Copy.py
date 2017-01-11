from django.conf import settings
#from django.conf.urls import include, patterns, url
from django.conf.urls import include, url
from django.contrib import admin
from django.views import static

from trip.views import (Trip_Commitment,StudentUpdateView)
from . import views

#from . import views

admin.autodiscover()

app_name = 'trip'
urlpatterns = [
    url(r'^$', Trip_Commitment.as_view(), name='singletableview'),
    #url(r'^student/(?P<pk>\d+)/edit/$', views.student_edit, name='student_edit'),
    url(r'^student/(?P<pk>[\w-]+)/$', StudentUpdateView.as_view(), name='student'),
    #url(r'^student/(?P<pk>\d+)/$', student_detail, name='student_detail'),
    #url(r'^student/(?P<pk>\d+)/$', views.student_detail, name='student_detail'),
    url(r'^student/new/$', views.student_new, name='student_new'),
    #url(r'^jim/$', JimView.as_view(), name='jim'),
#    url(r'^$', IndexView.as_view(), name='index'),
#    url(r'^(?P<pk>[0-9]+)/$', DetailView.as_view(), name='detail'),
#    url(r'^(?P<pk>[0-9]+)/results/$', views.ResultsView.as_view(), name='results'),
#    url(r'^(?P<question_id>[0-9]+)/vote/$', views.vote, name='vote'),
]
if settings.DEBUG:
    import debug_toolbar
    #urlpatterns += patterns('',
    urlpatterns += [
        url(r'^__debug__/', include(debug_toolbar.urls)),
    ]
