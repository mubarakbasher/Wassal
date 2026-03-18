import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

const SOFT_DELETE_MODELS = ['User', 'Router', 'Voucher', 'Sale'];

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();

    // Soft-delete middleware: findMany, findFirst, findUnique, count, aggregate
    this.$use(async (params, next) => {
      if (!SOFT_DELETE_MODELS.includes(params.model ?? '')) {
        return next(params);
      }

      const readActions = ['findFirst', 'findMany', 'findUnique', 'findFirstOrThrow', 'findUniqueOrThrow', 'count', 'aggregate', 'groupBy'];

      if (readActions.includes(params.action)) {
        if (!params.args) params.args = {};
        if (params.args.where) {
          if (params.args.where.deletedAt === undefined) {
            params.args.where.deletedAt = null;
          }
        } else {
          params.args.where = { deletedAt: null };
        }
      }

      // Intercept delete -> soft delete
      if (params.action === 'delete') {
        params.action = 'update';
        params.args.data = { deletedAt: new Date() };
      }

      if (params.action === 'deleteMany') {
        params.action = 'updateMany';
        if (!params.args) params.args = {};
        if (!params.args.data) params.args.data = {};
        params.args.data.deletedAt = new Date();
      }

      return next(params);
    });
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Perform a hard delete bypassing soft-delete middleware.
   * Use only for cleanup tasks (e.g., expired tokens, RADIUS sync).
   */
  async hardDelete<T>(model: string, where: any): Promise<T> {
    return (this as any)[model].deleteMany({ where });
  }
}
