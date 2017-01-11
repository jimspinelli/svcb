# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-15 04:35
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0017_auto_20161114_2318'),
    ]

    operations = [
        migrations.CreateModel(
            name='Fund_Raiser_Profit',
            fields=[
                ('id', models.AutoField(primary_key=True, serialize=False)),
                ('profit', models.DecimalField(decimal_places=2, max_digits=6, verbose_name='profit')),
                ('date_entered', models.DateTimeField(auto_now_add=True, verbose_name='date_Entered')),
                ('trip', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='fund_raiser_profits', to='trip.Trip')),
            ],
        ),
    ]