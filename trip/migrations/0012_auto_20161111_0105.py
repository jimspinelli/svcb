# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2016-11-11 06:05
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0011_auto_20161111_0029'),
    ]

    operations = [
        migrations.RenameField(
            model_name='trip_commitment',
            old_name='grade',
            new_name='student_grade',
        ),
    ]