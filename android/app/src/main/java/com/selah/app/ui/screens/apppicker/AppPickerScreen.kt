package com.selah.app.ui.screens.apppicker

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.repeatOnLifecycle
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.graphics.drawable.toBitmap
import androidx.lifecycle.viewmodel.compose.viewModel
import com.selah.app.data.model.AppInfo
import com.selah.app.ui.theme.SelahColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppPickerScreen(
    onNavigateBack: () -> Unit,
    onComplete: () -> Unit,
    viewModel: AppPickerViewModel = viewModel()
) {
    val state by viewModel.state.collectAsState()
    val sheetState = rememberModalBottomSheetState()
    val lifecycleOwner = LocalLifecycleOwner.current

    // Refresh app list when screen becomes visible (e.g., after installing new app)
    LaunchedEffect(lifecycleOwner) {
        lifecycleOwner.repeatOnLifecycle(Lifecycle.State.RESUMED) {
            viewModel.refreshApps()
        }
    }

    // Limit reached bottom sheet
    if (state.showLimitDialog) {
        ModalBottomSheet(
            onDismissRequest = { viewModel.dismissLimitDialog() },
            sheetState = sheetState,
            containerColor = SelahColors.DeepNavy
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    "✦",
                    fontSize = 40.sp,
                    color = SelahColors.SacredGold
                )
                Spacer(Modifier.height(16.dp))
                Text(
                    "Free Plan Limit",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = SelahColors.WarmCream
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "You've selected ${state.selectedPackages.size} apps, but the free plan only allows 3.\n\nPlease deselect some apps or upgrade to Premium for unlimited.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = SelahColors.WarmCream.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center
                )
                Spacer(Modifier.height(24.dp))
                Button(
                    onClick = {
                        viewModel.dismissLimitDialog()
                        // TODO: Navigate to premium purchase
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = SelahColors.SacredGold,
                        contentColor = SelahColors.DeepNavy
                    ),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(16.dp)
                ) {
                    Text(
                        "Upgrade to Premium",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                Spacer(Modifier.height(8.dp))
                TextButton(
                    onClick = { viewModel.dismissLimitDialog() }
                ) {
                    Text(
                        "Go back and deselect",
                        color = SelahColors.WarmCream.copy(alpha = 0.7f)
                    )
                }
                Spacer(Modifier.height(16.dp))
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            "Choose Apps to Guard",
                            style = MaterialTheme.typography.titleLarge
                        )
                        Text(
                            "${state.selectedPackages.size} selected" +
                                if (!state.isPremium) " (max ${state.maxApps} free)" else "",
                            style = MaterialTheme.typography.bodySmall,
                            color = SelahColors.SacredGold
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = SelahColors.DeepNavy,
                    titleContentColor = SelahColors.WarmCream,
                    navigationIconContentColor = SelahColors.WarmCream
                )
            )
        },
        bottomBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(SelahColors.DeepNavy)
                    .padding(16.dp)
            ) {
                Button(
                    onClick = {
                        viewModel.saveSelections(
                            onComplete = onComplete,
                            onShowPremium = { /* TODO: Navigate to premium */ }
                        )
                    },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = state.selectedPackages.isNotEmpty() && !state.isSaving,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = SelahColors.SacredGold,
                        contentColor = SelahColors.DeepNavy,
                        disabledContainerColor = SelahColors.SubduedGray.copy(alpha = 0.3f),
                        disabledContentColor = SelahColors.SubduedGray
                    ),
                    shape = RoundedCornerShape(12.dp),
                    contentPadding = PaddingValues(16.dp)
                ) {
                    if (state.isSaving) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = SelahColors.DeepNavy,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Text(
                            "Save & Continue",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }
        },
        containerColor = SelahColors.DeepNavy
    ) { paddingValues ->
        if (state.isLoading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = SelahColors.SacredGold)
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Suggested apps section
                if (state.suggestedApps.isNotEmpty()) {
                    item {
                        Text(
                            "Suggested Apps",
                            style = MaterialTheme.typography.titleSmall,
                            color = SelahColors.SacredGold,
                            modifier = Modifier.padding(bottom = 8.dp, top = 8.dp)
                        )
                    }

                    items(state.suggestedApps, key = { it.packageName }) { app ->
                        AppRow(
                            app = app,
                            isSelected = viewModel.isSelected(app.packageName),
                            onToggle = { viewModel.toggleApp(app.packageName, app.appName) }
                        )
                    }
                }

                // Other apps section
                if (state.otherApps.isNotEmpty()) {
                    item {
                        Text(
                            "All Apps",
                            style = MaterialTheme.typography.titleSmall,
                            color = SelahColors.SacredGold,
                            modifier = Modifier.padding(bottom = 8.dp, top = 16.dp)
                        )
                    }

                    items(state.otherApps, key = { it.packageName }) { app ->
                        AppRow(
                            app = app,
                            isSelected = viewModel.isSelected(app.packageName),
                            onToggle = { viewModel.toggleApp(app.packageName, app.appName) }
                        )
                    }
                }

                // Bottom spacing
                item {
                    Spacer(Modifier.height(16.dp))
                }
            }
        }
    }
}

@Composable
private fun AppRow(
    app: AppInfo,
    isSelected: Boolean,
    onToggle: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onToggle() },
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                SelahColors.SacredGold.copy(alpha = 0.15f)
            } else {
                SelahColors.DeepNavy
            }
        ),
        shape = RoundedCornerShape(12.dp),
        border = if (isSelected) {
            androidx.compose.foundation.BorderStroke(1.dp, SelahColors.SacredGold.copy(alpha = 0.5f))
        } else {
            androidx.compose.foundation.BorderStroke(1.dp, SelahColors.SacredGold.copy(alpha = 0.1f))
        }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // App icon
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(SelahColors.WarmCream.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                app.icon?.let { drawable ->
                    Image(
                        bitmap = drawable.toBitmap(48, 48).asImageBitmap(),
                        contentDescription = app.appName,
                        modifier = Modifier.size(40.dp)
                    )
                }
            }

            Spacer(Modifier.width(12.dp))

            // App name
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    app.appName,
                    style = MaterialTheme.typography.bodyLarge,
                    color = SelahColors.WarmCream
                )
                if (app.isSuggested) {
                    Text(
                        "Commonly guarded",
                        style = MaterialTheme.typography.bodySmall,
                        fontStyle = FontStyle.Italic,
                        color = SelahColors.SacredGold.copy(alpha = 0.7f)
                    )
                }
            }

            // Checkbox
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelected) {
                            SelahColors.SacredGold
                        } else {
                            SelahColors.SacredGold.copy(alpha = 0.1f)
                        }
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelected) {
                    Icon(
                        Icons.Default.Check,
                        contentDescription = "Selected",
                        modifier = Modifier.size(18.dp),
                        tint = SelahColors.DeepNavy
                    )
                }
            }
        }
    }
}
