# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-28 18:25
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0024_trip_commitment_student'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='trip_commitment',
            name='email',
        ),
        migrations.RemoveField(
            model_name='trip_commitment',
            name='first_name',
        ),
        migrations.RemoveField(
            model_name='trip_commitment',
            name='last_name',
        ),
        migrations.RemoveField(
            model_name='trip_commitment',
            name='phone_1',
        ),
        migrations.RemoveField(
            model_name='trip_commitment',
            name='phone_2',
        ),
    ]
