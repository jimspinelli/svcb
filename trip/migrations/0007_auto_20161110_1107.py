# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-10 16:07
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0006_trip_school_year'),
    ]

    operations = [
        migrations.AddField(
            model_name='trip',
            name='trip_end_date',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='trip',
            name='trip_start_date',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_company',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_company_contact',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_company_email',
            field=models.CharField(blank=True, max_length=75, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_company_phone',
            field=models.CharField(blank=True, max_length=15, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_coordinator',
            field=models.CharField(blank=True, max_length=200, null=True),
        ),
        migrations.AlterField(
            model_name='trip',
            name='trip_coordinator_email',
            field=models.CharField(blank=True, max_length=75, null=True),
        ),
    ]
