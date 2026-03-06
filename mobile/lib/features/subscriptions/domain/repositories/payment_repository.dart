import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentModel>>> getMyPayments();
  Future<Either<Failure, BankInfo>> getBankInfo();
  Future<Either<Failure, void>> uploadProof(String paymentId, File imageFile);
}
