import 'dart:io';

import 'package:app/core/errors/exceptions.dart' as core_exception;
import 'package:app/features/auth/data/models/orgnization_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrganizationRemoteDataSource {
  /// Get organizations created by a user
  // Future<List<OrganizationModel>> getOrganizations(String userId);

  /// Get single organization by id
  Future<OrganizationModel> getOrganizationById(String organizationId);

  /// Create organization
  Future<OrganizationModel> createOrganization(OrganizationModel organization);

  /// Update organization
  Future<OrganizationModel> updateOrganization(
    String organizationId,
    OrganizationModel organization,
  );

  /// Delete organization
  Future<void> deleteOrganization(String organizationId);

  /// Upload logo
  Future<String> uploadOrganizationLogo(File logoFile, String organizationId);

  /// Delete logo from storage
  Future<void> deleteOrganizationLogo(String logoUrl);

  /// Update logo url
  Future<OrganizationModel> updateOrganizationLogoUrl(
    String organizationId,
    String logoUrl,
    String? existingLogoToDelete,
  );

  /// Remove logo url
  Future<OrganizationModel> deleteOrganizationLogoUrl(
    String organizationId,
    String logoUrlToDelete,
  );

  // Get the organization memners
  Future<List<UserModel>> getOrganizationMembers(String organizationId);
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final SupabaseClient supabaseClient;

  const OrganizationRemoteDataSourceImpl({required this.supabaseClient});

  // @override
  // Future<List<OrganizationModel>> getOrganizations(String userId) async {
  //   try {
  //     final response = await supabaseClient
  //         .from('organizations')
  //         .select()
  //         .eq('created_by', userId)
  //         .order('created_at', ascending: false);

  //     return (response as List)
  //         .map((e) => OrganizationModel.fromJson(e))
  //         .toList();
  //   } catch (e) {
  //     throw core_exception.ServerException('Failed to get organizations: $e');
  //   }
  // }

  @override
  Future<OrganizationModel> getOrganizationById(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('organizations')
          .select()
          .eq('id', organizationId)
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to get organization detail: $e',
      );
    }
  }

  @override
  Future<OrganizationModel> createOrganization(
    OrganizationModel organization,
  ) async {
    try {
      final response = await supabaseClient
          .from('organizations')
          .insert(organization.toJson())
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to create organization: $e');
    }
  }

  @override
  Future<OrganizationModel> updateOrganization(
    String organizationId,
    OrganizationModel organization,
  ) async {
    try {
      final response = await supabaseClient
          .from('organizations')
          .update(organization.toUpdateJson())
          .eq('id', organizationId)
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException('Failed to update organization: $e');
    }
  }

  @override
  Future<void> deleteOrganization(String organizationId) async {
    try {
      await supabaseClient
          .from('organizations')
          .delete()
          .eq('id', organizationId);
    } catch (e) {
      throw core_exception.ServerException('Failed to delete organization: $e');
    }
  }

  @override
  Future<String> uploadOrganizationLogo(
    File logoFile,
    String organizationId,
  ) async {
    try {
      final ext = logoFile.path.split('.').last;

      final fileName =
          '$organizationId/${organizationId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await supabaseClient.storage
          .from('organization-logos')
          .upload(fileName, logoFile);

      final url = supabaseClient.storage
          .from('organization-logos')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to upload organization logo: $e',
      );
    }
  }

  @override
  Future<void> deleteOrganizationLogo(String logoUrl) async {
    try {
      if (logoUrl.isEmpty) return;

      final uri = Uri.parse(logoUrl);
      final segments = uri.pathSegments;

      final bucketIndex = segments.indexOf('organization-logos');

      if (bucketIndex == -1 || bucketIndex >= segments.length - 1) return;

      final filePath = segments.sublist(bucketIndex + 1).join('/');

      await supabaseClient.storage.from('organization-logos').remove([
        filePath,
      ]);
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to delete organization logo: $e',
      );
    }
  }

  @override
  Future<OrganizationModel> updateOrganizationLogoUrl(
    String organizationId,
    String logoUrl,
    String? existingLogoToDelete,
  ) async {
    try {
      if (existingLogoToDelete != null &&
          existingLogoToDelete.trim().isNotEmpty) {
        await deleteOrganizationLogo(existingLogoToDelete);
      }

      final response = await supabaseClient
          .from('organizations')
          .update({'logo_url': logoUrl})
          .eq('id', organizationId)
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to update organization logo: $e',
      );
    }
  }

  @override
  Future<OrganizationModel> deleteOrganizationLogoUrl(
    String organizationId,
    String logoUrlToDelete,
  ) async {
    try {
      await deleteOrganizationLogo(logoUrlToDelete);

      final response = await supabaseClient
          .from('organizations')
          .update({'logo_url': null})
          .eq('id', organizationId)
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to remove organization logo: $e',
      );
    }
  }

  @override
  Future<List<UserModel>> getOrganizationMembers(String organizationId) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select('''
          id,
          user_id,
          full_name,
          image_url,
          role,
          phone,
          address,
          created_at,
          updated_at
        ''')
          .eq('organization_id', organizationId)
          .order('role', ascending: true)
          .order('full_name', ascending: true);

      // print('From remote data source: ${response.length}');
      // print(response);

      final member = response.map((user) => UserModel.fromJson(user)).toList();
      return member;
    } catch (e) {
      throw core_exception.ServerException(
        'Failed to get the organization members: $e',
      );
    }
  }
}
