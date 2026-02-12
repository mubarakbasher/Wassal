import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ProfilesService } from './profiles.service';
import { CreateProfileDto, UpdateProfileDto } from './dto/profile.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SubscriptionGuard } from '../auth/guards/subscription.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('profiles')
@UseGuards(JwtAuthGuard, SubscriptionGuard)
export class ProfilesController {
    constructor(private readonly profilesService: ProfilesService) { }

    @Post()
    create(@CurrentUser() user: any, @Body() createProfileDto: CreateProfileDto) {
        return this.profilesService.create(user.id, createProfileDto);
    }

    @Get()
    findAll(@CurrentUser() user: any, @Query('routerId') routerId?: string) {
        return this.profilesService.findAll(user.id, routerId);
    }

    @Get(':id')
    findOne(@Param('id') id: string, @CurrentUser() user: any) {
        return this.profilesService.findOne(id, user.id);
    }

    @Put(':id')
    update(
        @Param('id') id: string,
        @CurrentUser() user: any,
        @Body() updateProfileDto: UpdateProfileDto,
    ) {
        return this.profilesService.update(id, user.id, updateProfileDto);
    }

    @Delete(':id')
    @HttpCode(HttpStatus.OK)
    remove(@Param('id') id: string, @CurrentUser() user: any) {
        return this.profilesService.remove(id, user.id);
    }
}
