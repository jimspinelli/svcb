# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-10 06:48
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Fund_Raiser',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('description', models.CharField(max_length=200)),
                ('profit', models.DecimalField(decimal_places=2, max_digits=6)),
                ('profit_percentage', models.DecimalField(decimal_places=2, max_digits=5)),
            ],
        ),
        migrations.CreateModel(
            name='Fund_Raiser_Type',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('description', models.CharField(max_length=200)),
            ],
        ),
        migrations.CreateModel(
            name='Trip',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('description', models.CharField(max_length=200)),
                ('trip_cost', models.DecimalField(decimal_places=2, max_digits=6)),
                ('insurance_cost', models.DecimalField(decimal_places=2, max_digits=6)),
                ('trip_company', models.CharField(max_length=200)),
                ('trip_company_contact', models.CharField(max_length=200)),
                ('trip_company_phone', models.CharField(max_length=15)),
                ('trip_company_email', models.CharField(max_length=75)),
                ('trip_coordinator', models.CharField(max_length=200)),
                ('trip_coordinator_email', models.CharField(max_length=75)),
            ],
        ),
        migrations.CreateModel(
            name='Trip_Commitment',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('grade', models.CharField(choices=[('8', '8'), ('9', '9'), ('10', '10'), ('11', '11'), ('12', '12')], max_length=2)),
                ('period', models.CharField(max_length=2)),
                ('going_on_trip', models.CharField(default='U', max_length=1)),
                ('purchase_insurance', models.BooleanField(default=0)),
                ('first_name', models.CharField(max_length=255)),
                ('last_name', models.CharField(max_length=255)),
                ('email', models.CharField(max_length=75)),
                ('phone_1', models.CharField(max_length=15)),
                ('phone_2', models.CharField(max_length=15)),
                ('trip', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='trip.Trip')),
            ],
        ),
        migrations.AddField(
            model_name='fund_raiser',
            name='fund_raiser_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='trip.Fund_Raiser_Type'),
        ),
        migrations.AddField(
            model_name='fund_raiser',
            name='trip',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='trip.Trip'),
        ),
    ]
