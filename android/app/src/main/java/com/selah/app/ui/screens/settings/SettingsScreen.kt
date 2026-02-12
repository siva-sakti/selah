package com.selah.app.ui.screens.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.selah.app.ui.theme.SelahColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    onNavigateToAppPicker: () -> Unit,
    viewModel: SettingsViewModel = viewModel()
) {
    val state by viewModel.state.collectAsState()
    val sheetState = rememberModalBottomSheetState()
    var showCommitmentSheet by remember { mutableStateOf(false) }
    var commitmentDraft by remember(state.commitment) { mutableStateOf(state.commitment ?: "") }

    // Commitment editing bottom sheet
    if (showCommitmentSheet) {
        ModalBottomSheet(
            onDismissRequest = { showCommitmentSheet = false },
            sheetState = sheetState,
            containerColor = SelahColors.DeepNavy
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp)
            ) {
                Text(
                    "Personal Commitment",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = SelahColors.WarmCream
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "Write a message to remind yourself why you're choosing prayer over distraction.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = SelahColors.WarmCream.copy(alpha = 0.7f)
                )
                Spacer(Modifier.height(16.dp))
                OutlinedTextField(
                    value = commitmentDraft,
                    onValueChange = { commitmentDraft = it },
                    modifier = Modifier.fillMaxWidth(),
                    placeholder = {
                        Text(
                            "e.g., I choose presence over scrolling...",
                            color = SelahColors.SubduedGray
                        )
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = SelahColors.WarmCream,
                        unfocusedTextColor = SelahColors.WarmCream,
                        focusedBorderColor = SelahColors.SacredGold,
                        unfocusedBorderColor = SelahColors.SacredGold.copy(alpha = 0.3f),
                        cursorColor = SelahColors.SacredGold
                    ),
                    minLines = 3,
                    maxLines = 5
                )
                Spacer(Modifier.height(24.dp))
                Button(
                    onClick = {
                        viewModel.saveCommitment(commitmentDraft.ifBlank { null })
                        showCommitmentSheet = false
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = SelahColors.SacredGold,
                        contentColor = SelahColors.DeepNavy
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text(
                        "Save",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                if (!state.commitment.isNullOrBlank()) {
                    Spacer(Modifier.height(8.dp))
                    TextButton(
                        onClick = {
                            viewModel.saveCommitment(null)
                            commitmentDraft = ""
                            showCommitmentSheet = false
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            "Clear commitment",
                            color = SelahColors.WarmCream.copy(alpha = 0.5f)
                        )
                    }
                }
                Spacer(Modifier.height(16.dp))
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Settings",
                        style = MaterialTheme.typography.headlineMedium
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = SelahColors.DeepNavy,
                    titleContentColor = SelahColors.WarmCream
                )
            )
        },
        containerColor = SelahColors.DeepNavy
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Section header
            Text(
                "Protection",
                style = MaterialTheme.typography.titleSmall,
                color = SelahColors.SacredGold,
                modifier = Modifier.padding(bottom = 4.dp)
            )

            // Guarded Apps row
            SettingsRow(
                icon = {
                    Icon(
                        Icons.Default.Shield,
                        contentDescription = null,
                        tint = SelahColors.SacredGold,
                        modifier = Modifier.size(24.dp)
                    )
                },
                title = "Guarded Apps",
                subtitle = "Choose which apps to guard",
                onClick = onNavigateToAppPicker
            )

            // Personal Commitment row
            SettingsRow(
                icon = {
                    Icon(
                        Icons.Default.Edit,
                        contentDescription = null,
                        tint = SelahColors.SacredGold,
                        modifier = Modifier.size(24.dp)
                    )
                },
                title = "Personal Commitment",
                subtitle = if (state.commitment.isNullOrBlank()) {
                    "Add a message to yourself"
                } else {
                    state.commitment!!.take(40) + if (state.commitment!!.length > 40) "..." else ""
                },
                onClick = { showCommitmentSheet = true }
            )

            Spacer(Modifier.height(24.dp))

            // More settings sections can be added here
            Text(
                "About",
                style = MaterialTheme.typography.titleSmall,
                color = SelahColors.SacredGold,
                modifier = Modifier.padding(bottom = 4.dp)
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = SelahColors.SacredGold.copy(alpha = 0.1f)
                ),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        "✦",
                        fontSize = 32.sp,
                        color = SelahColors.SacredGold
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "Selah",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.SemiBold,
                        color = SelahColors.WarmCream
                    )
                    Text(
                        "A moment of sacred pause",
                        style = MaterialTheme.typography.bodySmall,
                        color = SelahColors.WarmCream.copy(alpha = 0.7f)
                    )
                }
            }
        }
    }
}

@Composable
private fun SettingsRow(
    icon: @Composable () -> Unit,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = SelahColors.SacredGold.copy(alpha = 0.1f)
        ),
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            icon()

            Spacer(Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    title,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Medium,
                    color = SelahColors.WarmCream
                )
                Text(
                    subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = SelahColors.WarmCream.copy(alpha = 0.7f)
                )
            }

            Icon(
                Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = SelahColors.SacredGold.copy(alpha = 0.5f)
            )
        }
    }
}
